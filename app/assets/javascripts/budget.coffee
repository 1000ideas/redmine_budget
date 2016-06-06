class BudgetPlugin
  constructor: ->
    jQuery =>
      @_init_budget_calculator()
      @_init_time_calculator()

    true

  _init_budget_calculator: ->
    _root = $('.redmine_budget')
    return if _root.length == 0
    
    # koszt bazowy    overhead    acc cost    profit    rate
    # 31,30%          25,04%      10,33%      33,33%    100,00%
    _cost_per_hour = parseFloat($('[name=cost_per_hour]', _root).val())
    _rate = _cost_per_hour + (_cost_per_hour * 0.8) + (_cost_per_hour * 0.33)
    _rate = Math.ceil(_rate + (_rate * 0.5))
    $('[name=rate]', _root).val(_rate)
    _rate_base_cost = _rate * 0.313
    _rate_overhead = _rate * 0.2504
    _rate_acc_cost = _rate * 0.1033
    $('[name=budget]', _root).val(160)
    $('[name=burned]', _root).val(1)

    $('[name=budget],[name=burned]',_root).on 'change', ->
      _budget = parseFloat($('[name=budget]', _root).val())
      _burned = parseFloat($('[name=burned]', _root).val())
      $('[name=available]', _root).val(_budget / _rate)
      $('[name=cost]', _root).val(_cost=(_burned * _rate_base_cost))
      $('[name=overhead]', _root).val(_overhead=(_burned * _rate_overhead))
      $('[name=acc_cost]', _root).val(_acc_cost=(_burned * _rate_acc_cost))
      $('[name=profit]', _root).val(_budget - (_cost+_overhead+_acc_cost))

    $('[name=budget]',_root).trigger 'change'

  _init_time_calculator: ->
    _root = $('form.time_calculator')
    return if _root.length == 0

    $('[name=hours]',_root).val("test")



window.BudgetPlugin = new BudgetPlugin()

