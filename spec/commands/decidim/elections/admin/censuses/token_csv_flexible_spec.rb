# frozen_string_literal: true

require "rails_helper"
require "decidim/elections/test/factories"

module Decidim
  module Elections
    module Admin
      module Censuses
        describe TokenCsvFlexible do
          subject { described_class.new(form, election) }

          let(:organization) { create(:organization) }
          let(:participatory_process) { create(:participatory_process, organization:) }
          let(:component) { create(:elections_component, participatory_space: participatory_process) }
          let(:election) { create(:election, component:) }

          let(:data) { [%w(user123 token1), %w(user456 token2)] }
          let(:form) do
            double(
              "Decidim::Elections::Admin::Censuses::TokenCsvFlexibleForm",
              invalid?: invalid, remove_all:, file:, data:
            )
          end

          let(:invalid) { false }
          let(:remove_all) { false }
          let(:file) { true }

          describe "#call" do
            context "when the form is invalid" do
              let(:invalid) { true }

              it { expect { subject.call }.to broadcast(:invalid) }
            end

            context "when remove_all is true but no census is set" do
              let(:remove_all) { true }

              before { allow(election).to receive(:census).and_return(nil) }

              it { expect { subject.call }.to broadcast(:invalid) }
            end

            context "when remove_all is true and census exists" do
              let(:remove_all) { true }

              before do
                election.update!(census_manifest: :token_csv_flexible)
                election.reload
                create(:election_voter, election:, data: { id: "user123", token: "token1" })
              end

              it "deletes all voters" do
                expect { subject.call }.to change { election.voters.count }.from(1).to(0)
              end

              it "broadcasts :ok" do
                subject.call
                expect(subject).to broadcast(:ok)
              end
            end

            context "when file is not present" do
              let(:file) { nil }

              it { expect { subject.call }.to broadcast(:invalid) }
            end

            context "when data is blank" do
              let(:data) { [] }

              it { expect { subject.call }.to broadcast(:invalid) }
            end

            context "when everything is valid" do
              it do
                expect { subject.call }.to change { election.voters.count }.by(2).and broadcast(:ok)

                ids = election.voters.map { |v| v.data["id"] }
                expect(ids).to include("user123", "user456")
              end
            end

            context "when data has duplicates" do
              let(:data) { [%w(user123 token1), %w(user123 token2), %w(user456 token3)] }

              it "creates voters for all rows (duplicates should be handled by form/parser)" do
                expect { subject.call }.to change { election.voters.count }.by(3).and broadcast(:ok)
              end
            end
          end
        end
      end
    end
  end
end
