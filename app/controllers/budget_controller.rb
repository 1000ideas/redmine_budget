include ActionView::Helpers::TextHelper

class BudgetController < ApplicationController
  unloadable

  # skip_before_filter :check_if_login_required
  # skip_before_filter :verify_authenticity_token

  # accept_api_auth :check_for_new_deals

  def calculator
  end
end
