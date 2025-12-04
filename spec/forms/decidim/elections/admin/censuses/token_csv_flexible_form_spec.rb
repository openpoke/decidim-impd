# frozen_string_literal: true

require "rails_helper"
require "decidim/elections/test/factories"

module Decidim
  module Elections
    module Admin
      module Censuses
        describe TokenCsvFlexibleForm do
          let(:organization) { create(:organization) }
          let(:attributes) { { file: file, remove_all: remove_all } }
          let(:remove_all) { false }

          subject { described_class.new(attributes).with_context(current_organization: organization) }

          describe "#data" do
            context "when file is present and valid" do
              let(:file) { upload_test_file(file_fixture("valid_flexible_census.csv").to_s, content_type: "text/csv") }

              it "parses and returns data" do
                expect(subject.data).to eq([%w(user123 token123), %w(user456 token456)])
              end
            end

            context "when file has duplicate ids" do
              let(:file) { upload_test_file(file_fixture("flexible_census_duplicate_ids.csv").to_s, content_type: "text/csv") }

              it "removes duplicates and keeps only first occurrence" do
                expect(subject.data).to eq([%w(user123 TOKEN123)])
              end
            end

            context "when file is blank" do
              let(:file) { nil }

              it "returns an empty array" do
                expect(subject.data).to eq([])
              end
            end
          end

          describe "#errors_data" do
            context "when file is present and valid" do
              let(:file) { upload_test_file(file_fixture("valid_flexible_census.csv").to_s, content_type: "text/csv") }

              it "returns an empty array" do
                expect(subject.errors_data).to eq([])
              end
            end

            context "when file has rows with missing id" do
              let(:file) { upload_test_file(file_fixture("flexible_census_with_missing_id.csv").to_s, content_type: "text/csv") }

              it "returns an array with errors" do
                expect(subject.errors_data).not_to be_empty
              end
            end
          end

          describe "#validations" do
            context "when remove_all is blank and file is missing" do
              let(:file) { nil }

              it "is invalid" do
                expect(subject).not_to be_valid
                expect(subject.errors[:file]).to include(I18n.t("errors.messages.blank"))
              end
            end

            context "when remove_all is true" do
              let(:file) { nil }
              let(:remove_all) { true }

              it "is valid even without a file" do
                expect(subject).to be_valid
              end
            end

            context "when file is present but not CSV" do
              let(:file) { upload_test_file(Decidim::Dev.test_file("avatar.jpg", "image/jpeg")) }

              it "is invalid" do
                expect(subject).not_to be_valid
                expect(subject.errors[:file]).to include("only files with the following extensions are allowed: csv")
              end
            end
          end
        end
      end
    end
  end
end
