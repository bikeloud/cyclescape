# frozen_string_literal: true

require "spec_helper"

describe "User preferences" do
  include_context "signed in as a site user"

  def get_field(name)
    find_field(I18n.t("formtastic.labels.user_pref.#{name}"))
  end

  before do
    visit current_user_prefs_edit_path
  end

  describe "involvement in user location matters" do
    it "should default to subscribed" do
      within("#user_pref_involve_my_locations_input") do
        expect(page).to have_checked_field(I18n.t(".user.prefs.edit.subscribe"))
      end
    end

    it "should change to none" do
      within("#user_pref_involve_my_locations_input") do
        page.choose(I18n.t(".user.prefs.edit.none"))
      end
      click_on "Save"
      within("#user_pref_involve_my_locations_input") do
        expect(page).to have_checked_field(I18n.t(".user.prefs.edit.none"))
      end
      current_user.reload
      expect(current_user.prefs.involve_my_locations).to eql("none")
    end
  end

  describe "involvement in group matters" do
    it "should default to notify" do
      within("#user_pref_involve_my_groups_input") do
        expect(page).to have_checked_field(I18n.t(".user.prefs.edit.notify"))
        expect(page).not_to have_checked_field(I18n.t(".user.prefs.edit.subscribe"))
        expect(page).not_to have_checked_field(I18n.t(".user.prefs.edit.none"))
      end
    end

    it "should change to subscribed" do
      within("#user_pref_involve_my_groups_input") do
        page.choose(I18n.t(".user.prefs.edit.subscribe"))
      end
      click_on "Save"
      within("#user_pref_involve_my_groups_input") do
        expect(page).to have_checked_field(I18n.t(".user.prefs.edit.subscribe"))
        expect(page).not_to have_checked_field(I18n.t(".user.prefs.edit.notify"))
      end
      current_user.reload
      expect(current_user.prefs.involve_my_groups).to eql("subscribe")
    end
  end

  describe "involvement in group admin matters" do
    let(:field) { get_field("involve_my_groups_admin") }

    it "should default to off" do
      expect(field).not_to be_checked
    end

    it "should switch on" do
      field.set true
      click_on "Save"
      current_user.reload
      expect(current_user.prefs.involve_my_groups_admin).to be_truthy
    end
  end

  describe "enable email" do
    let(:field) { get_field("email_status_id") }

    it "should default to off" do
      expect(page).to have_checked_field(I18n.t("email_status.no_email"))
    end

    it "should switch on" do
      page.choose(I18n.t("email_status.digest"))
      click_on "Save"
      expect(page).to have_checked_field(I18n.t("email_status.digest"))
    end
  end
end
