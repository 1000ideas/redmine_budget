include ActionView::Helpers::TextHelper

class BudgetController < ApplicationController
  unloadable

  # skip_before_filter :check_if_login_required
  # skip_before_filter :verify_authenticity_token

  # accept_api_auth :check_for_new_deals

  def index
  	@settings = Setting[:plugin_redmine_budget]
  end

  def calculate
  	@result = {}
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
  		@result = {
  			rate: rate,
  			work_cost: work_cost
  		}
  	when "issue"
  		unless params[:issue_id].blank? 
	  		issue = Issue.where(id: params[:issue_id]).first

	  		if !issue.estimated_hours.blank? and !issue.budget.blank?
				total_work_cost = issue.spent_hours * work_cost
				additional_cost = 0
		  		profit = (issue.budget - (total_work_cost + additional_cost)).ceil
		  		provision = (profit * provision).ceil

		  		@result = {
		  			estimated: issue.estimated_hours,
		  			spent: issue.spent_hours,
		  			budget: issue.budget,
		  			profit: profit,
		  			provision: provision
		  		}
		  	end
	  	end
  	when "budget"
  		@result = []

  		params[:estimation].each do |row|
	  		hours = row[:hours].to_f
	  		base_rate = row[:rate].to_f

			rate = ( base_rate * rate_factor ).ceil

			total_work_cost = ( (hours * cost_factor) * base_rate ).ceil
			middle_bid = ( (hours * rate_factor) * base_rate ).ceil
			lower_bid = ( middle_bid * 0.85 ).ceil
			upper_bid = ( middle_bid * 1.15 ).ceil

	  		@result << {
	  			work_cost: total_work_cost,
	  			lower_bid: lower_bid,
	  			middle_bid: middle_bid,
	  			upper_bid: upper_bid
	  		}
	  	end

	  	additional_cost = params[:additionals].sum{|row| row[:cost].to_f }

	  	@result << {
	  		total_work_cost: @result.sum{|row| row[:work_cost] } + additional_cost,
	  		total_lower_bid: @result.sum{|row| row[:lower_bid] } + additional_cost,
	  		total_middle_bid: @result.sum{|row| row[:middle_bid] } + additional_cost,
	  		total_upper_bid: @result.sum{|row| row[:upper_bid] } + additional_cost
	  	}
  	end

  	respond_to do |format|
  		format.html { render layout: false }
  		format.json { render json: @result }
  	end
  end
end
