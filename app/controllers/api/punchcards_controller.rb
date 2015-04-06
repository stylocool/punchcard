class Api::PunchcardsController < ApplicationController
  before_filter :authenticate_user_from_token!
  respond_to :json

  def user_for_paper_trail
    if current_user.present?
      current_user.id
    else
      email = request.headers["X-API-EMAIL"].presence
      user = User.find_by_email(email)
      if user.present?
        user.id
      end
    end
  end

  def create
    @punchcard = Punchcard.new(mobile_params)
    if @punchcard.save
      redirect_to api_punchcard_path(@punchcard)
    end
  end

  def show
    @punchcard = Punchcard.find(params[:id])
  end

  def mobile_params
    params.permit(:checkin, :checkout, :checkin_location, :checkout_location, :company_id, :project_id, :worker_id)
  end
end