include ActionView::Helpers::TextHelper

class BudgetController < ApplicationController
  unloadable

  # skip_before_filter :check_if_login_required
  # skip_before_filter :verify_authenticity_token

  # accept_api_auth :check_for_new_deals

  def index
  end

  def calculate
  	result = {}
  	settings = Setting[:plugin_redmine_budget]

	rate_factor = settings[:rate_factor].to_f
	base_rate = params.has_key?(:rate) ? params[:rate].to_f : settings[:default_rate].to_f
	rate = ( base_rate * rate_factor ).ceil

	cost_factor = settings[:cost_factor].to_f
	work_cost = ( base_rate * cost_factor ).ceil

	profit_share = settings[:profit_share].to_f
	provision = settings[:provision].to_f

  	case params[:type]
  	when "rate"
  		result = {
  			rate: rate,
  			work_cost: work_cost
  		}
  	when "issue"
  		issue = Issue.find(params[:issue_id])

		total_work_cost = issue.spent_hours * work_cost
		additional_cost = 0
  		profit = (issue.budget - (total_work_cost + additional_cost)).ceil
  		provision = (profit * provision).ceil

  		result = {
  			estimated: issue.estimated_hours,
  			spent: issue.spent_hours,
  			budget: issue.budget,
  			profit: profit,
  			provision: provision
  		}
  	when "budget"
  		hours = params[:hours].to_f

		total_work_cost = ( (hours * cost_factor) * base_rate ).ceil
		middle_bid = ( (hours * rate_factor) * base_rate ).ceil
		lower_bid = ( middle_bid * 0.85 ).ceil
		upper_bid = ( middle_bid * 1.15 ).ceil

  		result = {
  			work_cost: total_work_cost,
  			lower_bid: lower_bid,
  			middle_bid: middle_bid,
  			upper_bid: upper_bid
  		}
  	end

  	render json: result
  end
end
