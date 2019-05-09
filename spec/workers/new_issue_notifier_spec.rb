# frozen_string_literal: true

require "spec_helper"

describe NewIssueNotifier do
  subject { NewIssueNotifier }

  let(:issue) { double("issue", id: 99) }

  # Queueing interface
  it { is_expected.to respond_to(:perform) }
  it { expect(subject.queue).to eq(:mailers) }

  describe ".new_issue" do
    it "should queue process_new_issue with the issue ID" do
      expect(Resque).to receive(:enqueue).with(NewIssueNotifier, :process_new_issue, 99)
      subject.new_issue(issue)
    end
  end

  context "processing" do
    describe ".process_for_user_locations" do
      let(:user) { create(:user) }
      let(:issue) { create(:issue) }
      let(:location) { create(:user_location, loc_json: issue.loc_json, user: user) }

      before do
        user.prefs.update_column(:involve_my_locations, "notify")
        user.prefs.update_column(:email_status_id, 1)
      end

      it "should queue a notification for each user that has preference set" do
        opts = { "location_id" => location.id, "issue_id" => issue.id }
        expect(Resque).to receive(:enqueue).with(NewIssueNotifier, :notify_new_user_location_issue, opts)
        subject.process_new_issue(issue.id)
      end
    end
  end
end
