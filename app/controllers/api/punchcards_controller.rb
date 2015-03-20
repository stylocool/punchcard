class Api::PunchcardsController < ApplicationController
  before_filter :authenticate_user_from_token!
  respond_to :json

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