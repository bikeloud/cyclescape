# frozen_string_literal: true

require "spec_helper"

describe "Issues in a group subdomain" do
  include_context "signed in as a group member"
  include_context "with current group subdomain"

  let(:location_inside_group) { "POINT (10 10)" }
  let(:location_outside_group) { "POINT (200 200)" }
  let!(:issues) { create_list(:issue, 2, location: location_inside_group) }
  let!(:outside_issue) { create(:issue, location: location_outside_group) }

  before do
    # Groups create empty profiles automatically, so just update the existing one
    current_group.profile.location = "POLYGON ((0 0, 0 100, 100 100, 100 0, 0 0))"
    current_group.profile.save!
  end

  context "index" do
    it "should show issues in the group's area" do
      visit issues_path
      issues.each do |issue|
        expect(page).to have_content(issue.title)
      end
    end

    it "should not show issues outside the group's area" do
      outside_issue
      visit issues_path
      expect(page).to have_no_content(outside_issue.title)
    end

    it "should set the page title" do
      visit issues_path
      expect(page).to have_title(I18n.t("group.issues.index.title", group_name: current_group.name))
    end
  end

  context "geojson" do
    context "all issues" do
      it "should show issues in the group's area" do
        visit all_geometries_issues_path(format: :json)

        issues.each do |issue|
          expect(page).to have_content(issue.title)
        end
      end

      it "should not show issues outside the group's area" do
        outside_issue
        visit all_geometries_issues_path(format: :json)

        expect(page).to have_no_content(outside_issue.title)
      end
    end
  end

  context "editing" do
    let(:issue) { create(:issue, created_by: current_user) }
    let(:edit_text) { "Edit this issue" }

    # Check decl_auth context is set correctly for nested controller
    it "should let you edit the issue" do
      visit issue_path(issue)
      click_on edit_text
      expect(page).to have_content("Edit Issue")
      fill_in "Title", with: "Something New"
      click_on "Save"
      issue.reload
      expect(current_path).to eq(issue_path(issue))
      expect(page).to have_content("Something New")
    end
  end
end
