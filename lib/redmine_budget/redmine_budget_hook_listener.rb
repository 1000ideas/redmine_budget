module RedmineBudget
  class RedmineBudgetHookListener < Redmine::Hook::ViewListener
    render_on :view_issues_show_description_bottom, partial: 'additional_costs/show'
    render_on :view_issues_form_details_bottom, partial: 'additional_costs/new'
  end
end
