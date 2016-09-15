class AdditionalCosts
  _root: null
  constructor: ->
    @._root = $('.issue-additional-costs')

    @._init_add_new_cost()

    true

  _init_add_new_cost: ->
    issue_id = @._root.data('issueId')
    $(@._root).on 'click', '#add-new-cost', =>
      @.addNewCost(issue_id)
    $(@._root).on 'click', '.del-cost', (ev) ->
      window.AdditionalCosts.deleteCost(ev, issue_id)

  addNewCost: (issue_id) ->
    $.ajax {
      type: 'POST',
      url: "/issues/#{issue_id}/additional_cost",
      data: {
        additional_cost: {
          name: $('#additional_cost_name', @._root).val(),
          cost: $('#additional_cost_cost', @._root).val()
        }
      },
      success: (data) ->
        $(data).insertBefore('#additional-costs-form', @._root)
        $('#additional_cost_name, #additional_cost_cost', @._root).each (idx, el) ->
          $(el).val('')
    }

  deleteCost: (ev, issue_id) ->
    wrapper = $(ev).parent()
    id = $('.cost-name', wrapper).data('costId')
    $.ajax {
      type: 'DELETE',
      url: "/issues/#{issue_id}/additional_cost/#{id}",
      success: (data) ->
        $(wrapper).remove()
    }

$(document).on 'ready page:load', ->
  window.AdditionalCosts = new AdditionalCosts()
