module BudgetHelper
  def user_costs(user_id, time_entries)
    rate_avg = []
    hours_sum = 0
    cost_sum = 0
    time_entries.each do |time|
      rate = Rate.order('id DESC')
                 .where(user_id: user_id, project_id: time.project_id, date_in_effect: (10.years.ago...time.created_on))
                 .limit(1)
                 .first
      rate = (rate.present? ? rate.amount.to_f : @settings[:default_rate].to_f)

      rate_avg << rate
      hours_sum += time.hours
      cost_sum += time.hours * rate
    end

    line = []
    line << content_tag(:td, (rate_avg.reduce(:+) / rate_avg.size.to_f).round(2))
    line << content_tag(:td, hours_sum.to_f.round(2))
    line << content_tag(:td, cost_sum.to_f.round(2))
    line.join.html_safe
  end

  def issue_link(issue)
    "##{issue.id} #{issue.subject}"
  end

  def filter_options
    ['Project', 'Assignee']
  end

  def filter_values(op)
    return nil unless ['Project', 'User'].include? op
    op.constantize.all.inject([]) { |res, obj| res << [obj.name, obj.id] }
  end
end
