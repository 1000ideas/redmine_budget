get 'budget', to: 'budget#index', as: :budget
get 'budget/calculate', to: 'budget#calculate', as: :budget_calculate
get 'budget/issues', to: 'budget#issues', as: :budget_issues

post 'issues/:issue_id/additional_cost', to: 'additional_costs#create', as: :additional_cost
delete 'issues/:issue_id/additional_cost/:id', to: 'additional_costs#destroy', as: :additional_cost
