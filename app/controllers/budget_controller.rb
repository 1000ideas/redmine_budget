include ActionView::Helpers::TextHelper

class BudgetController < ApplicationController
  unloadable

  # skip_before_filter :check_if_login_required
  # skip_before_filter :verify_authenticity_token

  # accept_api_auth :check_for_new_deals

  before_filter :find_settings, only: [:index, :issues, :calculate]

  def index
    @issue = Issue.find(params[:issue_id]) if params[:issue_id].present?
  end

  def issues
    @issues = Issue.where(tracker_id: @settings[:tracker_id] || 5)
    exclude_issues
    apply_filter if view_context.filter_options.include? params[:filter_option]
  end

  def calculate
    @result = {}

    cost_factor = @settings[:cost_factor].to_f
    rate_factor = @settings[:rate_factor].to_f
    base_rate = params.key?(:rate) ? params[:rate].to_f : @settings[:default_rate].to_f

    rate = (base_rate * rate_factor).ceil
    work_cost = (base_rate * cost_factor).ceil

    # profit_share = @settings[:profit_share].to_f
    # provision = @settings[:provision].to_f

    case params[:type]
    when 'rate'
      @result = {
        rate: rate,
        work_cost: work_cost
      }
    when 'budget'
      count_estimate_budget(cost_factor, rate_factor)
    end

    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: @result }
    end
  end

  private

  def find_settings
    @settings ||= Setting[:plugin_redmine_budget]
  end

  def apply_filter
    case params[:filter_option]
    when 'Project'
      @issues = @issues.where(project_id: params[:filter_value])
    when 'Category'
      @issues = @issues.where(category_id: params[:filter_value])
    when 'Assignee'
      @issues = @issues.where(assigned_to_id: params[:filter_value])
    end
  end

  def exclude_issues
    @issues = @issues.open
    unless User.current.can_manage_budget?
      @issues = @issues.where(assigned_to_id: User.current.id)
    end
  end

  def count_estimate_budget(cost_factor, rate_factor)
    @result = []

    params[:estimation].each do |row|
      hours = row[:hours].to_f
      base_rate = row[:rate].to_f

      total_work_cost = ((hours * cost_factor) * base_rate).ceil
      middle_bid = ((hours * rate_factor) * base_rate).ceil
      lower_bid = (middle_bid * (1.0 - @settings[:margin].to_f)).ceil
      upper_bid = (middle_bid * (1.0 + @settings[:margin].to_f)).ceil

      @result << {
        work_cost: total_work_cost,
        lower_bid: lower_bid,
        middle_bid: middle_bid,
        upper_bid: upper_bid
      }
    end

    additional_cost = params[:additionals].sum { |row| row[:cost].to_f }

    @result << {
      total_work_cost: @result.sum { |row| row[:work_cost] } + additional_cost,
      total_lower_bid: @result.sum { |row| row[:lower_bid] } + additional_cost,
      total_middle_bid: @result.sum { |row| row[:middle_bid] } + additional_cost,
      total_upper_bid: @result.sum { |row| row[:upper_bid] } + additional_cost
    }
  end
end
