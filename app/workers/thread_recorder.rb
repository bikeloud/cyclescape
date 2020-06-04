# frozen_string_literal: true

class ThreadRecorder
  extend Resque::Plugins::ExponentialBackoff
  @retry_limit = 3

  def self.queue
    :medium
  end

  # Call +method+ with *args on ourself
  def self.perform(method, *args)
    send(method, *args)
  end

  # Main entry point - queue that the thread is viewed right now.
  def self.thread_viewed(thread, user)
    Resque.enqueue(ThreadRecorder, :record_thread_viewed, thread.id, user.id, Time.current)
  end

  # Update the database with when the thread was last viewed
  def self.record_thread_viewed(thread_id, user_id, time_str)
    view = ThreadView.find_or_initialize_by(thread_id: thread_id, user_id: user_id)
    view.viewed_at = time_str
    view.save!
  end
end
