class BudgetIssues
  constructor: ->
    @._query_form = $('#budget-query-form')
    return if @._query_form.length == 0

    @._init_filtering()

    true

  _init_filtering: ->
    @._change_filter_values()
    $('#filter-options select', @._query_form).on 'change', =>
      @._change_filter_values()

  _change_filter_values: ->
    op = $('#filter-options select', @._query_form).val()
    $('.filter-values', @._query_form).each (idx, el) ->
      $('select', $(el)).prop('disabled', true)
      $(el).hide()
    $("#filter-#{op.toLowerCase()}", @._query_form).show()
    $("#filter-#{op.toLowerCase()} select", @._query_form).prop('disabled', false).show()

$(document).on 'ready page:load', ->
  window.BudgetIssues = new BudgetIssues()
