module RedmineBudget
  class RedmineBudgetHookListener < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom, partial: 'additional_costs/new'
    render_on :view_issues_show_description_bottom, partial: 'budget/budget'
  end
end
