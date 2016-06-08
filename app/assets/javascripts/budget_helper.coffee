class BudgetHelper
  _cost_per_hour: null
  _rate: null
  _rate_base_cost: null
  _rate_overhead: null
  _rate_acc_cost: null
  constructor: ->
    true

  rates: (_cost_per_hour) ->
    @._cost_per_hour = parseFloat(_cost_per_hour)
    @._rate = @._cost_per_hour + (@._cost_per_hour * 0.8) + (@._cost_per_hour * 0.33)
    @._rate = @._rate + (@._rate * 0.5)
    @._rate_base_cost = @._rate * 0.313
    @._rate_overhead = @._rate * 0.2504
    @._rate_acc_cost = @._rate * 0.1033

    [@._rate, @._rate_overhead, @._rate_acc_cost, @._rate_base_cost]

  budget: (_budget, _burned, _cost_per_hour = null) ->
    if @._rate is null and _cost_per_hour is not null
      [@._rate, @._rate_overhead, @._rate_acc_cost, @._rate_base_cost] = @.rates(_cost_per_hour)

    _budget = parseFloat(_budget)
    _burned = parseFloat(_burned)
    _available = (_budget / @._rate)
    _cost = (_cost=(_burned * @._rate_base_cost))
    _overhead = (_overhead=(_burned * @._rate_overhead))
    _acc_cost = (_acc_cost=(_burned * @._rate_acc_cost))
    _profit = _budget - (_cost+_overhead+_acc_cost)
    _score = _profit / (_budget * 0.33)

    _percent = Math.floor(100 * Math.max(0, ((3.030303 + _score) / 6.06060606)))


    [_budget, _burned, _available, _cost, _overhead, _acc_cost, _profit, _score, _percent]

  requiredBudget: (_hours, _cost_per_hour = null) ->
    if @._rate is null and _cost_per_hour is not null
      [@._rate, @._rate_overhead, @._rate_acc_cost, @._rate_base_cost] = @.rates(_cost_per_hour)

    parseFloat(_hours) * @._rate


window.BudgetHelper = new BudgetHelper()

