include ActionView::Helpers::TextHelper

class BudgetController < ApplicationController
  unloadable

  # skip_before_filter :check_if_login_required
  # skip_before_filter :verify_authenticity_token

  # accept_api_auth :check_for_new_deals

  def index
    @settings = Setting[:plugin_redmine_budget]
    @issue = Issue.find(params[:issue_id]) if params[:issue_id].present?
  end

  def issues
    @settings = Setting[:plugin_redmine_budget]
    @issues = Issue.where(tracker_id: @settings[:tracker_id] || 5) # TODO: remove closed issues and so on
    apply_filter if view_context.filter_options.include? params[:filter_option]
  end

  def calculate
    @result = {}
    @settings = Setting[:plugin_redmine_budget]

    rate_factor = @settings[:rate_factor].to_f
    base_rate = params.key?(:rate) ? params[:rate].to_f : @settings[:default_rate].to_f

    rate = (base_rate * rate_factor).ceil

    cost_factor = @settings[:cost_factor].to_f
    work_cost = (base_rate * cost_factor).ceil

    # profit_share = @settings[:profit_share].to_f
    provision = @settings[:provision].to_f

    case params[:type]
    when 'rate'
      @result = {
        rate: rate,
        work_cost: work_cost
      }
    when 'issue'
      if params[:issue_id].present?
        @issue = Issue.where(id: params[:issue_id]).first

        if @issue.spent_hours_with_children.present? && @issue.budget.present?
          total_work_cost = @issue.spent_hours_with_children * work_cost
          additional_cost = 0
          profit = (@issue.budget - (total_work_cost + additional_cost)).ceil
          provision = (profit * provision).ceil

          @result = {
            estimated: @issue.estimated_hours,
            spent: @issue.spent_hours_with_children,
            budget: @issue.budget,
            profit: profit,
            provision: provision
          }
        end
      end
    when 'budget'
      @result = []

      params[:estimation].each do |row|
        hours = row[:hours].to_f
        base_rate = row[:rate].to_f

        rate = (base_rate * rate_factor).ceil

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

      if params[:budget].present?
        @score = (((params[:budget].to_f / (@result.first[:middle_bid] + additional_cost)) - 1.0) * 100.0).round(2)
        @score = [[@score, 100].min, -100].max
      end

      @result << {
        total_work_cost: @result.sum { |row| row[:work_cost] } + additional_cost,
        total_lower_bid: @result.sum { |row| row[:lower_bid] } + additional_cost,
        total_middle_bid: @result.sum { |row| row[:middle_bid] } + additional_cost,
        total_upper_bid: @result.sum { |row| row[:upper_bid] } + additional_cost,
        total_score: @score
      }
    end

    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: @result }
    end
  end

  private

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
end
