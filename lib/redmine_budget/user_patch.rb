module RedmineBudget
  module UserPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
      end
    end

    module InstanceMethods
      def can_manage_budget?
        group_ids.include? Setting[:plugin_redmine_budget][:managers_id].to_i
      end

      def can_see_budget?
        group_ids.include?(Setting[:plugin_redmine_budget][:managers_id].to_i) ||
          group_ids.include?(Setting[:plugin_redmine_budget][:access_id].to_i)
      end
    end
  end
end
