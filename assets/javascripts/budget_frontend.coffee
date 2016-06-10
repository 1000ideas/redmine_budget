class BudgetFrotendPlugin
  _root: null
  constructor: ->
    jQuery =>
      @._root = $('.redmine_budget_frontend')
      return if @._root.length == 0

      @_init_budget_calculator()

    true

  _init_budget_calculator: ->
      [_rate, _rate_overhead, _rate_acc_cost, _rate_base_cost] = 
        window.BudgetHelper.rates(@._root.data('cost-per-hour'))

      [_budget, _burned, _available, _cost, _overhead, _acc_cost, _profit, _score, _percent] = 
        window.BudgetHelper.budget(@._root.data('budget'), @._root.data('estimated-hours'), @._root.data('cost-per-hour'))


      $('td.burned', @._root).html(_burned)
      $('td.profit', @._root).html(_profit)
      $('td.score', @._root).html(_score)


window.BudgetFrotendPlugin = new BudgetFrotendPlugin()

