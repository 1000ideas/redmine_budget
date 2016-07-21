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
      this._generate_blank_row();
      this._register_listeners();
      return this._get_data();
    };

    BudgetPlugin.prototype._generate_blank_row = function() {
      var row;
      row = $('.row:last', this._root);
      row.after(row.clone());
      return $('.row:last input', this._root).val("");
    };

    BudgetPlugin.prototype._register_listeners = function() {
      $('input', this._root).unbind('keyup change');
      return $('input', this._root).bind('keyup change', $.debounce((function(_this) {
        return function(ev) {
          var empties_length;
          empties_length = $.grep($(".row:last input", _this._root), (function(e) {
            return $(e).val().length > 0;
          })).length;
          if (empties_length === 2) {
            _this._generate_blank_row();
            _this._register_listeners();
          } else if (empties_length === 0) {
            $(ev.target).parent().parent().remove();
          }
          return _this._get_data();
        };
      })(this), 500, null, true));
    };

    BudgetPlugin.prototype._get_data = function() {
      return $.ajax("/budget/calculate?type=budget", {
        data: $('.row input', this._root).serializeArray(),
        success: function(data) {
          return $(data).each(function(i, e) {
            var r;
            r = $(".row:nth(" + i + ")");
            $('td:nth(2)', r).text(e.work_cost);
            $('td:nth(3)', r).text(e.lower_bid);
            $('td:nth(4)', r).text(e.middle_bid);
            return $('td:nth(5)', r).text(e.upper_bid);
          });
        }
      });
    };

    return BudgetPlugin;

  })();

  window.BudgetPlugin = new BudgetPlugin();

}).call(this);
