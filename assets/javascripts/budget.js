(function() {
  var BudgetPlugin;

  BudgetPlugin = (function() {
    BudgetPlugin.prototype._root = null;

    function BudgetPlugin() {
      jQuery((function(_this) {
        return function() {
          _this._root = $('.redmine_budget');
          if (_this._root.length === 0) {
            return;
          }
          return _this._init_budget_calculator();
        };
      })(this));
      true;
    }

    BudgetPlugin.prototype._init_budget_calculator = function() {
      var _budget_calculate, _rate, _rate_acc_cost, _rate_base_cost, _rate_calculate, _rate_overhead, _time_calculate;
      $('[name=budget]', this._root).val(160);
      $('[name=burned]', this._root).val(1);
      _rate = 0;
      _rate_base_cost = 0;
      _rate_overhead = 0;
      _rate_acc_cost = 0;
      _rate_calculate = function() {
        var ref;
        ref = window.BudgetHelper.rates($('[name=cost_per_hour]', this._root).val()), _rate = ref[0], _rate_overhead = ref[1], _rate_acc_cost = ref[2], _rate_base_cost = ref[3];
        $('[name=rate]', this._root).val(_rate);
        _budget_calculate();
        return _time_calculate();
      };
      _budget_calculate = function() {
        var _acc_cost, _available, _budget, _burned, _cost, _overhead, _percent, _profit, _score, ref;
        ref = window.BudgetHelper.budget($('[name=budget]', this._root).val(), $('[name=burned]', this._root).val(), $('[name=cost_per_hour]', this._root).val()), _budget = ref[0], _burned = ref[1], _available = ref[2], _cost = ref[3], _overhead = ref[4], _acc_cost = ref[5], _profit = ref[6], _score = ref[7], _percent = ref[8];
        $('[name=available]', this._root).val(_available);
        $('[name=cost]', this._root).val(_cost);
        $('[name=overhead]', this._root).val(_overhead);
        $('[name=acc_cost]', this._root).val(_acc_cost);
        $('[name=profit]', this._root).val(_profit);
        $('[name=score]', this._root).val(_score);
        return $('.score-indicator div', this._root).css({
          width: (Math.max(2, _percent)) + "%"
        }).attr({
          "class": "hue" + _percent
        });
      };
      _time_calculate = function() {
        var _required_budget;
        _required_budget = window.BudgetHelper.requiredBudget($('[name=hours]', this._root).val());
        return $('[name=required_budget]', this._root).val(_required_budget);
      };
      $('[name=cost_per_hour]', this._root).on('change keyup', _rate_calculate);
      $('[name=budget],[name=burned]', this._root).on('change keyup', _budget_calculate);
      $('[name=hours]', this._root).on('change keyup', _time_calculate);
      return $('[name=cost_per_hour]', this._root).trigger('change');
    };

    return BudgetPlugin;

  })();

  window.BudgetPlugin = new BudgetPlugin();

}).call(this);
