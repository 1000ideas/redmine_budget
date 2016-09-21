module RedmineBudget
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        has_many :additional_costs
        # belongs_to :rate
        # before_save :recalculate_cost
      end
    end

    module ClassMethods
      # Updated the cached cost of all TimeEntries for user and project
      # def update_cost_cache(user, project=nil)
      #   entries = TimeEntry.where(user_id: user.id)
      #   entries = entries.where(project_id: project.id) if project

      #   entries.each(&:save_cached_cost)
      # end
    end

    module InstanceMethods
      def budget?
        tracker_id.to_i == Setting[:plugin_redmine_budget][:tracker_id].to_i
      end

      def budget
        if (custom_field = custom_field_values.find { |cfv| cfv.custom_field.name =~ /budget/i })
          custom_field.value.to_f.round(2)
        else
          nil
        end
      end

      def work_cost
        factor = Setting[:plugin_redmine_budget][:cost_factor].to_f
        (work_cost_sum * factor).to_f.round(2)
      end

      def add_cost
        additional_costs.sum(&:cost).round(2)
      end

      def budget_score
        cost = work_cost + add_cost
        return 0 if cost.zero?
        res = (((budget / cost) - 1.0) * 100.0).round(2)
        return 100 if res > 100.0
        return -100 if res < -100.0
        res
      end

      def budget_profit
        # @settings = Setting[:plugin_redmine_budget]

        # # rate_factor = @settings[:rate_factor].to_f
        # base_rate = @settings[:default_rate].to_f

        # # rate = (base_rate * rate_factor).ceil

        # cost_factor = @settings[:cost_factor].to_f
        # work_cost = (base_rate * cost_factor).ceil

        # # profit_share = @settings[:profit_share].to_f
        # # provision = @settings[:provision].to_f

        # if spent_hours_with_children.present? && budget.present?
        #   total_work_cost = spent_hours_with_children * work_cost
        #   additional_cost = 0
        #   profit = (budget - (total_work_cost + additional_cost)).ceil
        #   # provision = (profit * provision).ceil

        #   # @result = {
        #   #   estimated: estimated_hours,
        #   #   spent: spent_hours_with_children,
        #   #   budget: budget,
        #   #   profit: profit,
        #   #   provision: provision
        #   # }
        #   profit
        # else
        #   nil
        # end
        budget - (work_cost + add_cost)
      end

      def spent_hours_with_children
        if children.count > 0
          spent_hours + children.sum(&:spent_hours_with_children)
        else
          spent_hours
        end
      end

      def time_entries_with_children
        if children.count > 0
          (time_entries.all + children.collect(&:time_entries_with_children)).flatten
        else
          time_entries.all
        end
      end

      def work_cost_sum
        cost_sum = 0
        time_entries_with_children.group_by(&:user_id).each do |user_id, time_entries|
          time_entries.each do |time|
            rate = Rate.order('id DESC')
                       .where(
                         user_id: user_id,
                         project_id: time.project_id,
                         date_in_effect: (10.years.ago...time.created_on)
                       )
                       .limit(1)
                       .first
            rate = (rate.present? ? rate.amount.to_f : @settings[:default_rate].to_f)

            cost_sum += time.hours * rate
          end
        end
        cost_sum
      end

      # Returns the current cost of the TimeEntry based on it's rate and hours
      #
      # Is a read-through cache method
      # def cost(options={})
      #   store_to_db = options[:store] || false

      #   unless read_attribute(:cost)
      #     if self.rate.nil?
      #       amount = Rate.amount_for(self.user, self.project, self.spent_on.to_s)
      #     else
      #       amount = rate.amount
      #     end

      #     if amount.nil?
      #       write_attribute(:cost, 0.0)
      #     else
      #       if store_to_db
      #         # Write the cost to the database for caching
      #         update_attribute(:cost, amount.to_f * hours.to_f)
      #       else
      #         # Cache to object only
      #         write_attribute(:cost, amount.to_f * hours.to_f)
      #       end
      #     end
      #   end

      #   read_attribute(:cost)
      # end

      # def clear_cost_cache
      #   write_attribute(:cost, nil)
      # end

      # def save_cached_cost
      #   clear_cost_cache
      #   update_attribute(:cost, cost)
      # end

      # def recalculate_cost
      #   clear_cost_cache
      #   cost(:store => false)
      #   true # for callback
      # end
    end
  end
end
