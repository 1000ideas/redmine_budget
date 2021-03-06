(function() {
  var BudgetHelper;

  BudgetHelper = (function() {
    BudgetHelper.prototype._cost_per_hour = null;

    BudgetHelper.prototype._rate = null;

    BudgetHelper.prototype._rate_base_cost = null;

    BudgetHelper.prototype._rate_overhead = null;

    BudgetHelper.prototype._rate_acc_cost = null;

    function BudgetHelper() {
      true;
    }

    BudgetHelper.prototype.rates = function(_cost_per_hour) {
      this._cost_per_hour = parseFloat(_cost_per_hour);
      this._rate = this._cost_per_hour + (this._cost_per_hour * 0.8) + (this._cost_per_hour * 0.33);
      this._rate = this._rate + (this._rate * 0.5);
      this._rate_base_cost = this._rate * 0.313;
      this._rate_overhead = this._rate * 0.2504;
      this._rate_acc_cost = this._rate * 0.1033;
      return [this._rate, this._rate_overhead, this._rate_acc_cost, this._rate_base_cost];
    };

    BudgetHelper.prototype.budget = function(_budget, _burned, _cost_per_hour) {
      var _acc_cost, _available, _cost, _overhead, _percent, _profit, _score;
      if (_cost_per_hour == null) {
        _cost_per_hour = null;
      }
      _budget = parseFloat(_budget);
      _burned = parseFloat(_burned);
      _available = _budget / this._rate;
      _cost = (_cost = _burned * this._rate_base_cost);
      _overhead = (_overhead = _burned * this._rate_overhead);
      _acc_cost = (_acc_cost = _burned * this._rate_acc_cost);
      _profit = _budget - (_cost + _overhead + _acc_cost);
      _score = _profit / (_budget * 0.33);
      _percent = Math.floor(100 * Math.max(0, (3.030303 + _score) / 6.06060606));
      return [_budget, _burned, _available, _cost, _overhead, _acc_cost, _profit, _score, _percent];
    };

    BudgetHelper.prototype.requiredBudget = function(_hours, _cost_per_hour) {
      var ref;
      if (_cost_per_hour == null) {
        _cost_per_hour = null;
      }
      if (this._rate === null && _cost_per_hour === !null) {
        ref = this.rates(_cost_per_hour), this._rate = ref[0], this._rate_overhead = ref[1], this._rate_acc_cost = ref[2], this._rate_base_cost = ref[3];
      }
      return parseFloat(_hours) * this._rate;
    };

    return BudgetHelper;

  })();

  window.BudgetHelper = new BudgetHelper();

}).call(this);
