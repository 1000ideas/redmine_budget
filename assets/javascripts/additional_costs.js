var AdditionalCosts;

AdditionalCosts = (function() {
  AdditionalCosts.prototype._root = null;

  function AdditionalCosts() {
    this._root = $('.issue-additional-costs');
    this._init_add_new_cost();
    true;
  }

  AdditionalCosts.prototype._init_add_new_cost = function() {
    var issue_id;
    issue_id = this._root.data('issueId');
    $(this._root).on('click', '#add-new-cost', (function(_this) {
      return function() {
        return _this.addNewCost(issue_id);
      };
    })(this));
    return $(this._root).on('click', '.del-cost', function(ev) {
      return window.AdditionalCosts.deleteCost(ev, issue_id);
    });
  };

  AdditionalCosts.prototype.addNewCost = function(issue_id) {
    return $.ajax({
      type: 'POST',
      url: "/issues/" + issue_id + "/additional_cost",
      data: {
        additional_cost: {
          name: $('#additional_cost_name', this._root).val(),
          cost: $('#additional_cost_cost', this._root).val()
        }
      },
      success: function(data) {
        $(data).insertBefore('#additional-costs-form', this._root);
        return $('#additional_cost_name, #additional_cost_cost', this._root).each(function(idx, el) {
          return $(el).val('');
        });
      }
    });
  };

  AdditionalCosts.prototype.deleteCost = function(ev, issue_id) {
    var id, wrapper;
    wrapper = $(ev.target).closest('.single-cost');
    id = $('.cost-name', wrapper).data('costId');
    return $.ajax({
      type: 'DELETE',
      url: "/issues/" + issue_id + "/additional_cost/" + id,
      success: function(data) {
        return $(wrapper).remove();
      }
    });
  };

  return AdditionalCosts;

})();

$(document).on('ready page:load', function() {
  return window.AdditionalCosts = new AdditionalCosts();
});
