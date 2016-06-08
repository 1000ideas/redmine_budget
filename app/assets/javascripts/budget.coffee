class BudgetPlugin
  _root: null
  constructor: ->
    jQuery =>
      @._root = $('.redmine_budget')
      return if @._root.length == 0

      @_init_budget_calculator()

    true

  _init_budget_calculator: ->
    
    # koszt bazowy    overhead    acc cost    profit    rate
    # 31,30%          25,04%      10,33%      33,33%    100,00%
    $('[name=budget]', @._root).val(160)
    $('[name=burned]', @._root).val(1)
    _rate = 0
    _rate_base_cost = 0
    _rate_overhead = 0
    _rate_acc_cost = 0

    _rate_calculate = ->
      [_rate, _rate_overhead, _rate_acc_cost, _rate_base_cost] = 
        window.BudgetHelper.rates($('[name=cost_per_hour]', @._root).val())

      $('[name=rate]', @._root).val(_rate)
      _budget_calculate()
      _time_calculate()


    _budget_calculate = ->
      [_budget, _burned, _available, _cost, _overhead, _acc_cost, _profit, _score, _percent] = 
        window.BudgetHelper.budget($('[name=budget]', @._root).val(), $('[name=burned]', @._root).val(), $('[name=cost_per_hour]', @._root).val())

      $('[name=available]', @._root).val(_available)
      $('[name=cost]', @._root).val(_cost)
      $('[name=overhead]', @._root).val(_overhead)
      $('[name=acc_cost]', @._root).val(_acc_cost)
      $('[name=profit]', @._root).val(_profit)
      $('[name=score]', @._root).val(_score)
      $('.score-indicator div', @._root).css(width: "#{Math.max(2,_percent)}%")
                                        .attr(class: "hue#{_percent}")

    _time_calculate = ->
      _required_budget = 
        window.BudgetHelper.requiredBudget($('[name=hours]', @._root).val())

      $('[name=required_budget]', @._root).val(_required_budget)



    $('[name=cost_per_hour]',@._root).on 'change keyup', _rate_calculate
    $('[name=budget],[name=burned]',@._root).on 'change keyup', _budget_calculate
    $('[name=hours]',@._root).on 'change keyup', _time_calculate

    $('[name=cost_per_hour]',@._root).trigger 'change'


window.BudgetPlugin = new BudgetPlugin()

