# frozen_string_literal: true

require "rails_helper"
require "decidim/elections/test/factories"

module Decidim
  module Elections
    module Censuses
      describe TokenCsvFlexibleForm do
        let(:election) { create(:election, :ongoing, census_manifest: :token_csv_flexible) }
        let!(:voter) { create(:election_voter, data: data, election: election) }
        let(:organization) { election.organization }

        let(:params) do
          {
            id: "user123",
            token: "secret_token"
          }
        end
        let(:data) do
          {
            id: "user123",
            token: "secret_token"
          }
        end

        subject { described_class.from_params(params).with_context(election: election) }

        it { is_expected.to be_valid }

        describe "#voter_uid" do
          it "returns the global ID of the voter in the census" do
            expect(subject.voter_uid).to eq(voter.to_global_id.to_s)
          end
        end

        context "when the voter is not in the census" do
          let(:params) { { id: "nonexistent", token: "secret_token" } }

          it { is_expected.not_to be_valid }

          it "returns nil" do
            expect(subject.voter_uid).to be_nil
          end
        end

        context "when the token is wrong" do
          let(:params) { { id: "user123", token: "wrong_token" } }

          it { is_expected.not_to be_valid }

          it "returns nil" do
            expect(subject.voter_uid).to be_nil
          end
        end

        context "when voter in another election" do
          let(:other_election) { create(:election, :ongoing, census_manifest: :token_csv_flexible) }
          let!(:voter) { create(:election_voter, data: data, election: other_election) }

          it { is_expected.not_to be_valid }

          it "does not return the voter from another election" do
            expect(subject.voter_uid).to be_nil
          end
        end

        context "when id and token have extra whitespace" do
          let(:params) { { id: "  user123  ", token: "  secret_token  " } }

          it { is_expected.to be_valid }

          it "strips whitespace and finds the voter" do
            expect(subject.voter_uid).to eq(voter.to_global_id.to_s)
          end
        end
      end
    end
  end
end
