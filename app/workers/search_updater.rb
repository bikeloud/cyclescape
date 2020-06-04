# frozen_string_literal: true

class SearchUpdater
  extend Resque::Plugins::ExponentialBackoff
  @retry_limit = 3

  def self.queue
    :medium
  end

  # Call +method+ with *args on ourself
  def self.perform(method, *args)
    send(method, *args)
  end

  # cheekily added, we have too many queues, low, medium and high priority is enough
  def self.update_relevant_planning_applications
    planning_filters = PlanningFilter.all

    PlanningApplication.transaction do
      PlanningApplication.find_each do |pa|
        new_relavant = pa.calculate_relevant(planning_filters)
        pa.update(relevant: new_relavant) if pa.relevant != new_relavant
      end
    end
  end

  def self.update_type(item, type)
    Resque.enqueue(SearchUpdater, type, item.id)
  end

  def self.process_thread(thread_id)
    thread = MessageThread.find(thread_id)
    Retryable.retryable(on: [IO::EAGAINWaitReadable, Net::ReadTimeout]) do
      Sunspot.index thread
      Sunspot.index thread.issue if thread.issue
      Sunspot.commit true
    end
  end

  def self.process_issue(issue_id)
    issue = Issue.with_deleted.find(issue_id)
    Retryable.retryable(on: [IO::EAGAINWaitReadable, Net::ReadTimeout]) do
      if issue.deleted_at
        Sunspot.remove issue
      else
        Sunspot.index issue
      end
      Sunspot.commit true
    end
  end
end
