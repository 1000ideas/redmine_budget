Redmine::Plugin.register :redmine_budget do
  name 'Redmine Budget plugin'
  author '1000ideas'
  description 'Plan your budget'
  version '0.0.1'
  url 'http://1000i.pl'
  author_url 'http://1000i.pl'

  settings default: { 
              tracker_id: Tracker.first.id
            },
            partial: 'redmine_budget/settings'
end
