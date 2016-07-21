class BudgetPlugin
  _root: null
  constructor: ->
    jQuery =>
      @._root = $('.redmine_budget')
      return if @._root.length == 0

      @_init_budget_calculator()

    true

  _init_budget_calculator: ->
    @._generate_blank_row()
    @._register_listeners()
    @._get_data()

  _generate_blank_row: ->
    row = $('.row:last', @._root)
    row.after( row.clone() )
    $('.row:last input', @._root).val("")

  _register_listeners: ->
    $('input', @._root).unbind 'keyup change'
    $('input', @._root).bind 'keyup change', $.debounce (ev) =>
        empties_length = $.grep($(".row:last input", @._root), ((e) -> $(e).val().length > 0) ).length
        if empties_length == 2
          @._generate_blank_row()
          @._register_listeners()
        else if empties_length == 0
          $(ev.target).parent().parent().remove()

        @._get_data()
      , 500, null, true


  _get_data: ->
    $.ajax "/budget/calculate?type=budget", {
        data: $('.row input', @._root).serializeArray(),
        success: (data) ->
          $(data).each (i, e) -> 
            r = $(".row:nth(#{i})")
            $('td:nth(2)', r).text( e.work_cost )
            $('td:nth(3)', r).text( e.lower_bid )
            $('td:nth(4)', r).text( e.middle_bid )
            $('td:nth(5)', r).text( e.upper_bid )
      }
    

window.BudgetPlugin = new BudgetPlugin()

