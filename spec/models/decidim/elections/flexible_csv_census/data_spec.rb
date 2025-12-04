# frozen_string_literal: true

require "rails_helper"

module Decidim
  module Elections
    module FlexibleCsvCensus
      describe Data do
        subject { described_class.new(file) }

        describe "#values" do
          context "when file has valid data" do
            let(:file) { Rails.root.join("spec/fixtures/files/valid_flexible_census.csv").open }

            it "returns array of id and token pairs" do
              expect(subject.values).to eq([%w(user123 token123), %w(user456 token456)])
            end

            it "returns no errors" do
              expect(subject.errors).to be_empty
            end
          end

          context "when file has duplicate ids" do
            let(:file) { Rails.root.join("spec/fixtures/files/flexible_census_duplicate_ids.csv").open }

            it "removes duplicates and keeps only the first occurrence" do
              expect(subject.values).to eq([%w(user123 TOKEN123)])
            end

            it "returns no errors for duplicates" do
              expect(subject.errors).to be_empty
            end
          end

          context "when file has missing id" do
            let(:file) { Rails.root.join("spec/fixtures/files/flexible_census_with_missing_id.csv").open }

            it "returns only valid rows" do
              expect(subject.values).to eq([%w(user456 token456)])
            end

            it "returns errors for invalid rows" do
              expect(subject.errors).not_to be_empty
            end
          end
        end
      end
    end
  end
end
