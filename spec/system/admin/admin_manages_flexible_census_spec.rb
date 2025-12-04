# frozen_string_literal: true

require "rails_helper"
require "decidim/elections/test/factories"

describe "Admin manages flexible census" do # rubocop:disable RSpec/DescribeClass
  let(:manifest_name) { "elections" }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "elections") }
  let!(:election) { create(:election, component: current_component) }
  let(:election_census_path) { Decidim::EngineRouter.admin_proxy(component).election_census_path(election) }
  let(:dashboard_path) { Decidim::EngineRouter.admin_proxy(component).dashboard_election_path(election) }

  include_context "when managing a component as an admin"

  before do
    visit election_census_path
  end

  context "when the admin selects unregistered participants with flexible ID" do
    context "when the csv file is valid" do
      it "uploads the CSV file and creates participants" do
        select "Unregistered participants with flexible ID (fixed)", from: "census_manifest"
        expect(page).to have_content("Upload a CSV file")
        dynamically_attach_file("token_csv_flexible_file", file_fixture("valid_flexible_census.csv"))

        click_on "Save and continue"
        expect(page).to have_content("Census updated successfully")
        within ".main-tabs-menu__tabs li.is-active" do
          expect(page).to have_content("Dashboard")
        end

        visit election_census_path

        expect(page).to have_content("There are currently 2 people")
        expect(page).to have_content("The preview list is limited to 5 records.")
        expect(page).to have_content("user123")
        expect(page).to have_content("user456")
      end
    end

    context "when the csv file has rows with missing id" do
      it "creates only valid participants" do
        select "Unregistered participants with flexible ID (fixed)", from: "census_manifest"
        expect(page).to have_content("Upload a CSV file")
        dynamically_attach_file("token_csv_flexible_file", file_fixture("flexible_census_with_missing_id.csv"))

        click_on "Save and continue"
        within ".main-tabs-menu__tabs li.is-active" do
          expect(page).to have_content("Dashboard")
        end

        visit election_census_path

        expect(page).to have_content("There is currently 1 person")
        expect(page).to have_content("user456")
      end
    end

    context "when the csv file has duplicate ids" do
      it "removes duplicates and keeps only first occurrence" do
        select "Unregistered participants with flexible ID (fixed)", from: "census_manifest"
        expect(page).to have_content("Upload a CSV file")
        dynamically_attach_file("token_csv_flexible_file", file_fixture("flexible_census_duplicate_ids.csv"))

        click_on "Save and continue"
        within ".main-tabs-menu__tabs li.is-active" do
          expect(page).to have_content("Dashboard")
        end

        visit election_census_path

        expect(page).to have_content("There is currently 1 person")
        expect(page).to have_content("user123")
      end
    end

    context "when removing all participants from census" do
      before do
        election.update!(census_manifest: :token_csv_flexible)
        create(:election_voter, election: election, data: { id: "user123", token: "token1" })
        create(:election_voter, election: election, data: { id: "user456", token: "token2" })
        visit election_census_path
      end

      it "removes all participants when checkbox is checked" do
        expect(page).to have_content("There are currently 2 people")

        check "Remove all current census data"
        click_on "Save and continue"

        visit election_census_path
        expect(page).to have_content("Upload a CSV file")
        expect(page).to have_no_content("There are currently")
      end
    end
  end
end
