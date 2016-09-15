(function() {
  var BudgetPlugin;

  BudgetPlugin = (function() {
    BudgetPlugin.prototype._root = null;

    function BudgetPlugin() {
      jQuery((function(_this) {
        return function() {
          _this._root = $('.redmine_budget');
          _this._query_form = $('#budget-query-form')
          if (_this._root.length === 0) {
            return;
          }
          _this._budget_calculate_path = $('.redmine_budget').data('budget-calculate-path');
          _this._init_filtering();
          _this._init_budget_control();
          return _this._init_budget_calculator();
        };
      })(this));
      true;
    }

    BudgetPlugin.prototype._init_filtering = function() {
      this._change_filter_values();
      $('#filter-options select', this._query_form).on('change', (function(_this) {
        return function() {
          return _this._change_filter_values();
        };
      })(this));
    };

    BudgetPlugin.prototype._init_budget_control = function() {
      this._get_issue_summary();
      return $('#issue_id').on('change blur', (function(_this) {
        return function(ev) {
          return _this._get_issue_summary();
        };
      })(this));
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
      return $.ajax(window.BudgetPlugin._budget_calculate_path + ".json?type=budget&budget=" + $('.budget_estimation').data('est-budget'), {
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
          $('tr:nth(3) td', r).text(summary.total_upper_bid);
          return $('tr:nth(4) td', r).text(summary.total_score + "%");
        }
      });
    };

    BudgetPlugin.prototype._get_issue_summary = function() {
      return $.ajax(window.BudgetPlugin._budget_calculate_path + ".html", {
        data: {
          type: "issue",
          issue_id: $('#issue_id').val()
        },
        success: function(data) {
          return $('.issue_control .budget_content', this._root).html(data);
        }
      });
    };

    BudgetPlugin.prototype._change_filter_values = function() {
      var op;
      op = $('#filter-options select', this._query_form).val();
      $('.filter-values').each(function(idx, el) {
        $('select', $(el)).prop('disabled', true);
        return $(el).hide();
      });

      $("#filter-" + (op.toLowerCase()) + ' select').prop('disabled', false);
      return $("#filter-" + (op.toLowerCase())).show();
    };

    return BudgetPlugin;

  })();

  window.BudgetPlugin = new BudgetPlugin();

}).call(this);
