match 'budget', :to => 'budget#index', :as => :budget, :via => [:get]
match 'budget/calculate', :to => 'budget#calculate', :as => :budget_calculate, :via => [:get]
match 'budget/user/:id', :to => 'budget#user', :as => :budget_user, :via => [:get]