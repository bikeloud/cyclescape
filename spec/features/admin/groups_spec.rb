# frozen_string_literal: true

require "spec_helper"

describe "Groups admin" do
  include_context "signed in as admin"

  let!(:groups) { create_list(:group, 3) }

  before do
    visit admin_groups_path
  end

  context "index" do
    it "should list all the groups" do
      expect(groups).not_to be_empty
      groups.each do |g|
        expect(page).to have_content(g.name)
      end
    end
  end

  context "new" do
    before do
      click_link I18n.t("admin.groups.index.new_group")
    end

    it "should let you create a new group" do
      fill_in "Name", with: "Placeford Cycling"
      fill_in "Subdomain", with: "placefordcc"
      fill_in "Website", with: "http://www.placefordcc.com"
      click_on "Create Group"
      expect(Group.where("name = 'Placeford Cycling'").count).to eq(1)
      expect(current_path).to eq(admin_groups_path)
      expect(page).to have_content("Placeford Cycling")
    end
  end

  context "edit" do
    before do
      within("table tr:first") do
        click_on "Edit", match: :first
      end
    end

    it "should update the group" do
      fill_in "Name", with: "Placeford Cycling Campaign"
      click_on "Save"
      expect(page.current_path).to eq(admin_groups_path)
      expect(page).to have_content("Placeford Cycling Campaign")
    end
  end
end
