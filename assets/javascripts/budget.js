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
          _this._init_budget_control();
          return _this._init_budget_calculator();
        };
      })(this));
      true;
    }

    BudgetPlugin.prototype._init_budget_control = function() {
      return $('#issue_id').on('change blur', function(ev) {
        return $.ajax("/budget/calculate.html", {
          data: {
            type: "issue",
            issue_id: $(ev.target).val()
          },
          success: function(data) {
            return $('.issue_control .budget_content', this._root).html(data);
          }
        });
      });
    };

    BudgetPlugin.prototype._init_budget_calculator = function() {
      $('table', this._root).each((function(_this) {
        return function(i, e) {
          return _this._register_listeners($(e));
        };
      })(this));
      return this._get_data();
    };

    BudgetPlugin.prototype._generate_blank_row = function(root) {
      var row;
      row = $('.row:last', root);
      row.after(row.clone());
      return $('.row:last input', root).val("");
    };

    BudgetPlugin.prototype._register_listeners = function(root) {
      $('.row input', root).unbind('keyup change');
      $('.row .remove', root).unbind('click');
      $('.row input', root).bind('keyup change', $.debounce((function(_this) {
        return function(ev) {
          if ($.grep($(".row:last input", root), (function(e) {
            return $(e).val().length > 0;
          })).length === 2) {
            _this._generate_blank_row(root);
            _this._register_listeners(root);
          }
          return _this._get_data();
        };
      })(this), 500, null, true));
      $('.row:not(:last) .remove', root).one('click', (function(_this) {
        return function(ev) {
          $(ev.target).parents(".row").remove();
          return _this._get_data();
        };
      })(this));
      return $('.row:last .remove', root).one('click', function() {
        return alert("Can't remove last row");
      });
    };

    BudgetPlugin.prototype._get_data = function() {
      return $.ajax("/budget/calculate.json?type=budget", {
        data: $('.budget_estimation .row input', this._root).serializeArray(),
        success: function(data) {
          var r, results, summary;
          results = $(data);
          summary = results.splice(-1)[0];
          results.each(function(i, e) {
            var r;
            r = $(".budget_estimation .row:nth(" + i + ")", this._root);
            $('td:nth(2)', r).text(e.work_cost);
            $('td:nth(3)', r).text(e.lower_bid);
            $('td:nth(4)', r).text(e.middle_bid);
            return $('td:nth(5)', r).text(e.upper_bid);
          });
          r = $(".summary", this._root);
          $('tr:nth(0) td', r).text(summary.total_work_cost);
          $('tr:nth(1) td', r).text(summary.total_lower_bid);
          $('tr:nth(2) td', r).text(summary.total_middle_bid);
          return $('tr:nth(3) td', r).text(summary.total_upper_bid);
        }
      });
    };

    return BudgetPlugin;

  })();

  window.BudgetPlugin = new BudgetPlugin();

}).call(this);
