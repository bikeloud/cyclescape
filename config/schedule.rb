# frozen_string_literal: true

require "yaml"

path = File.expand_path("schedule.yml", File.dirname(__FILE__))
config = {}
if File.exist?(path)
  config = YAML.safe_load(File.open(path))
elsif Rails.env.production?
  raise "The schedule.yml is missing, in production it must be present"
end

env(:PATH, "#{ENV['PATH']}:/usr/local/bin:#{config['path']}") if config["path"]
env(:HOME, config["home"]) if config["home"]
env(:MAILTO, config["error_email"]) if config["error_email"]

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Learn more: http://github.com/javan/whenever

every 5.minutes do
  rake "scheduled:process_all_mailboxes"
end

# This pulls in application from 5 days ago to 12 days ago (i.e. a weeks worth)
# They will be sorted with the oldest first.
# It looks like some Local Authorities (LAs) take a week or more to put the applications on-line.
# There is plenty of redudancy in this system but it balances getting up-to-date
# applications against missing applications from slow LAs.
# It will update the application if it already exists.
# PlanIt limit the results to 500.
#
# To get the past 6 months run this
# (1..180).step(15).each {|n_day| PlanningApplicationWorker.new(n_day.days.ago.to_date).process! }

every 1.day, at: "1:02 am" do
  rake "scheduled:new_planning_applications"
end

every 1.day, at: "2:02 am" do
  rake "scheduled:remove_old_planning_applications"
end

every 1.day, at: "6:55 am" do
  rake "scheduled:issue_upcoming_deadlines"
end

every 1.day, at: "7:05 am" do
  rake "scheduled:upcoming_deadlines"
end

every 1.day, at: "6:50 am" do
  rake "scheduled:email_user_digests"
end
