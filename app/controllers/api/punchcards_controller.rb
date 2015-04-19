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

    # Check if punchcard exist. If yes then update with the latest else create new.
    #if @punchcard.checkin.present? && !@punchcard.checkout.present?
    #  start = @punchcard.checkin.beginning_of_day
    #  stop = @punchcard.checkin.end_of_day
    #  exist = Punchcard.where("company_id = ? and project_id = ? and worker_id = ? and ((checkin is not null and checkin between ? and ?) or (checkout is not null and checkout between ? and ?))", @punchcard.company_id, @punchcard.project_id, @punchcard.worker_id, start, stop, start, stop).order('id desc').first
    #  if exist.present?
    #    exist.checkin = @punchcard.checkin
    #    exist.checkin_location = @punchcard.checkin_location
    #    if @punchcard.checkout.present?
    #      exist.checkout = @punchcard.checkout
    #      exist.checkout_location = @punchcard.checkout_location
    #    end
    #    @punchcard = exist
    #  end
    #elsif !@punchcard.checkin.present? && @punchcard.checkout.present?
    #  start = @punchcard.checkout.beginning_of_day
    #  stop = @punchcard.checkout.end_of_day
    #  exist = Punchcard.where("company_id = ? and project_id = ? and worker_id = ? and ((checkin is not null and checkin between ? and ?) or (checkout is not null and checkout between ? and ?))", @punchcard.company_id, @punchcard.project_id, @punchcard.worker_id, start, stop, start, stop).order('id desc').first
    #  if exist.present?
    #    exist.checkout = @punchcard.checkout
    #    exist.checkout_location = @punchcard.checkout_location
    #    if @punchcard.checkin.present?
    #      exist.checkin = @punchcard.checkin
    #      exist.checkin_location = @punchcard.checkin_location
    #    end
    #    @punchcard = exist
    #  end
    #elsif @punchcard.checkin.present? && @punchcard.checkout.present?
    #  start = @punchcard.checkin.beginning_of_day
    #  stop = @punchcard.checkin.end_of_day
    #  exist = Punchcard.where("company_id = ? and project_id = ? and worker_id = ? and ((checkin is not null and checkin between ? and ?) or (checkout is not null and checkout between ? and ?))", @punchcard.company_id, @punchcard.project_id, @punchcard.worker_id, start, stop, start, stop).order('id desc').first
    #  if exist.present?
    #    exist.checkin = @punchcard.checkin
    #    exist.checkin_location = @punchcard.checkin_location
    #    exist.checkout = @punchcard.checkout
    #    exist.checkout_location = @punchcard.checkout_location
    #    @punchcard = exist
    #  end
    #end

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