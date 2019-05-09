# frozen_string_literal: true

class UserPrefObserver < ActiveRecord::Observer
  def after_save(pref)
    if pref.involve_my_groups_admin_changed?
      user = pref.user
      if pref.involve_my_groups_admin
        user.groups.each do |group|
          group.threads.without_issue.each do |thread|
            thread.add_subscriber(user) if permissions_check(user, thread) && !user.ever_subscribed_to_thread?(thread)
          end
        end
      else
        user.groups.each do |group|
          group.threads.without_issue.each do |thread|
            if subscription = user.subscribed_to_thread?(thread)
              subscription.destroy
            end
          end
        end
      end
    end

    if pref.involve_my_groups_changed?
      user = pref.user
      if pref.involve_my_groups == "subscribe"
        user.groups.each do |group|
          group.threads.with_issue.each do |thread|
            thread.add_subscriber(user) if permissions_check(user, thread) && !user.ever_subscribed_to_thread?(thread)
          end
        end
      end

      if pref.involve_my_groups_was == "subscribe"
        user.groups.each do |group|
          group.threads.with_issue.each do |thread|
            next unless subscription = user.subscribed_to_thread?(thread)

            next if user.prefs.involve_my_locations == "subscribe" &&
                    user.buffered_location &&
                    thread.issue.location.intersects?(user.buffered_location)

            subscription.destroy
          end
        end
      end
    end

    if pref.involve_my_locations_changed?
      user = pref.user
      if pref.involve_my_locations == "subscribe"
        user.issues_near_locations.includes(:threads).find_each do |issue|
          issue.threads.each do |thread|
            thread.add_subscriber(user) if permissions_check(user, thread) && !user.ever_subscribed_to_thread?(thread)
          end
        end
      end

      if pref.involve_my_locations_was == "subscribe"
        local_thread_ids = user.issues_near_locations.includes(:threads).map { |iss| iss.threads.ids }.flatten.compact
        user.thread_subscriptions.includes(thread: :group).where(message_threads: { id: local_thread_ids }).references(:message_threads).find_each do |thread_sub|
          thread = thread_sub.thread

          next if thread.group&.members&.include?(user) &&
                  user.prefs.involve_my_groups == "subscribe"

          thread_sub.destroy
        end
      end
    end
  end

  def permissions_check(user, thread)
    Authorization::Engine.instance.permit? :show, object: thread, user: user, user_roles: %i[member guest]
  end
end
