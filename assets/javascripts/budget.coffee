class BudgetPlugin
  _root: null
  constructor: ->
    jQuery =>
      @._root = $('.redmine_budget')
      return if @._root.length == 0

      @._budget_calculate_path = $('.redmine_budget').data('budget-calculate-path')

      @._init_budget_calculator()

      true

  _init_budget_calculator: ->
    $('table', @._root).each (i, e) =>
      @._register_listeners($(e))

    @._get_data()

  _generate_blank_row: (root) ->
    row = $('.row:last', root)
    row.after( row.clone() )
    $('.row:last input', root).val("")

  _register_listeners: (root) ->
    $('.row input', root).unbind 'keyup change'
    $('.row .remove', root).unbind 'click'
    $('.row input', root).bind 'keyup change', $.debounce (ev) =>
        if $.grep($(".row:last input", root), ((e) -> $(e).val().length > 0) ).length == 2
          @._generate_blank_row(root)
          @._register_listeners(root)

        @._get_data()
      , 500, null, true

    $('.row:not(:last) .remove', root).one 'click', (ev) =>
      $(ev.target).parents(".row").remove()
      @._get_data()

    $('.row:last .remove', root).one 'click', ->
      alert("Can't remove last row")

  _get_data: ->
    $.ajax "#{window.BudgetPlugin._budget_calculate_path}.json?type=budget&budget=#{$('.budget_estimation').data('est-budget')}", {
        data: $('.budget_estimation .row input', @._root).serializeArray(),
        success: (data) ->
          results = $(data)
          summary = results.splice(-1)[0]
          results.each (i, e) ->
            r = $(".budget_estimation .row:nth(#{i})", @._root)
            $('td:nth(2)', r).text( e.work_cost )
            $('td:nth(3)', r).text( e.lower_bid )
            $('td:nth(4)', r).text( e.middle_bid )
            $('td:nth(5)', r).text( e.upper_bid )

          r = $(".summary", @._root)
          $('tr:nth(0) td', r).text( summary.total_work_cost )
          $('tr:nth(1) td', r).text( summary.total_lower_bid )
          $('tr:nth(2) td', r).text( summary.total_middle_bid )
          $('tr:nth(3) td', r).text( summary.total_upper_bid )
      }

$(document).on 'ready page:load', ->
  window.BudgetPlugin = new BudgetPlugin()
