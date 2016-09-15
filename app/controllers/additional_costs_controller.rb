class AdditionalCostsController < ApplicationController
  unloadable

  def create
    @issue = Issue.find(params[:issue_id])
    @cost = @issue.additional_costs.build(params[:additional_cost])

    if @cost.save
      render partial: 'additional_costs/cost', locals: { cost: @cost }
    end
  end

  def destroy
    @cost = AdditionalCost.find(params[:id])
    if @cost.destroy
      render text: 'ok'
    end
  end
end
