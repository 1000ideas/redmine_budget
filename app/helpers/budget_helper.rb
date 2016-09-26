module BudgetHelper
  def issue_link(issue)
    "##{issue.id} #{issue.subject}"
  end

  def filter_options
    arr = ['Project']
    arr << 'Assignee' if User.current.can_manage_budget?
    arr
  end

  def filter_values(op)
    return nil unless %w(Project User).include? op
    op.constantize.all.inject([]) { |a, e| a << [e.name, e.id] }
  end
end
