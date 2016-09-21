var BudgetIssues;

BudgetIssues = (function() {
  function BudgetIssues() {
    this._query_form = $('#budget-query-form');
    if (this._query_form.length === 0) {
      return;
    }
    this._init_filtering();
    true;
  }

  BudgetIssues.prototype._init_filtering = function() {
    this._change_filter_values();
    return $('#filter-options select', this._query_form).on('change', (function(_this) {
      return function() {
        return _this._change_filter_values();
      };
    })(this));
  };

  BudgetIssues.prototype._change_filter_values = function() {
    var op;
    op = $('#filter-options select', this._query_form).val();
    $('.filter-values', this._query_form).each(function(idx, el) {
      $('select', $(el)).prop('disabled', true);
      return $(el).hide();
    });
    $("#filter-" + (op.toLowerCase()), this._query_form).show();
    return $("#filter-" + (op.toLowerCase()) + " select", this._query_form).prop('disabled', false).show();
  };

  return BudgetIssues;

})();

$(document).on('ready page:load', function() {
  return window.BudgetIssues = new BudgetIssues();
});
