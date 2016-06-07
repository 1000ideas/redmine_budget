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
      _cost_per_hour = parseFloat($('[name=cost_per_hour]', @._root).val())
      _rate = _cost_per_hour + (_cost_per_hour * 0.8) + (_cost_per_hour * 0.33)
      _rate = _rate + (_rate * 0.5)
      $('[name=rate]', @._root).val(_rate)
      _rate_base_cost = _rate * 0.313
      _rate_overhead = _rate * 0.2504
      _rate_acc_cost = _rate * 0.1033
      _budget_calculate()
      _time_calculate()


    _budget_calculate = ->
      _budget = parseFloat($('[name=budget]', @._root).val())
      _burned = parseFloat($('[name=burned]', @._root).val())
      $('[name=available]', @._root).val(_budget / _rate)
      $('[name=cost]', @._root).val(_cost=(_burned * _rate_base_cost))
      $('[name=overhead]', @._root).val(_overhead=(_burned * _rate_overhead))
      $('[name=acc_cost]', @._root).val(_acc_cost=(_burned * _rate_acc_cost))
      _profit = _budget - (_cost+_overhead+_acc_cost)
      _score = _profit / (_budget * 0.33)
      $('[name=profit]', @._root).val(_profit)
      $('[name=score]', @._root).val(_score)

      percent = Math.floor(100 * Math.max(0, ((3.030303 + _score) / 6.06060606)))

      $('.score-indicator div', @._root).css(width: "#{Math.max(2,percent)}%")
                                        .attr(class: "hue#{percent}")

    _time_calculate = ->
      _hours = parseFloat($('[name=hours]', @._root).val())
      $('[name=required_budget]', @._root).val(_hours * _rate)


    $('[name=cost_per_hour]',@._root).on 'change keyup', _rate_calculate
    $('[name=budget],[name=burned]',@._root).on 'change keyup', _budget_calculate
    $('[name=hours]',@._root).on 'change keyup', _time_calculate

    $('[name=cost_per_hour]',@._root).trigger 'change'


window.BudgetPlugin = new BudgetPlugin()

