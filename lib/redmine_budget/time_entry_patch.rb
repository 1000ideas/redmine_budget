module RedmineBudget
  module TimeEntryPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        Rails.logger.error "Eval"

        after_create :budget_time_entry_added
        after_update :budget_time_entry_added
        before_destroy :budget_time_entry_deleted
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def budget_time_entry_added
        Rails.logger.error "SAVED1 1"
        # issue = Issue.find(issue_id)
        # issue.update_attributes(spent_time: issue.spent_time + hours)
      end

      def budget_time_entry_deleted
        Rails.logger.error "SAVED1 2"
        # issue = Issue.find(issue_id)
        # issue.update_attributes(spent_time: issue.spent_time - hours)
      end
    end
  end
end
