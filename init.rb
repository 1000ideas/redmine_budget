require_dependency 'redmine_budget/time_entry_patch'
require_dependency 'redmine_budget/issue_patch'
require_dependency 'redmine_budget/redmine_budget_hook_listener'

Redmine::Plugin.register :redmine_budget do
  name 'Redmine Budget plugin'
  author '1000ideas'
  description 'Plan your budget'
  version '0.0.1'
  url 'http://1000i.pl'
  author_url 'http://1000i.pl'

  menu :top_menu, :est_budget, { controller: :budget, action: :index }, caption: :top_menu_est, before: :projects
  menu :top_menu, :budget_issues, { controller: :budget, action: :issues }, caption: :top_menu_budget, before: :projects

  settings(
    default: {
      rate_factor: 2,
      cost_factor: 1.5,
      default_rate: 20,
      profit_share: 0.16,
      margin: 0.15,
      provision: 0.1,
      tracker_id: Tracker.first.id,
      group_id: Group.first.id
    },
    partial: 'redmine_budget/settings'
  )
end

Rails.configuration.to_prepare do
  TimeEntry.send(:include, RedmineBudget::TimeEntryPatch) unless TimeEntry.included_modules.include? RedmineBudget::TimeEntryPatch
  Issue.send(:include, RedmineBudget::IssuePatch) unless Issue.included_modules.include? RedmineBudget::IssuePatch
end
