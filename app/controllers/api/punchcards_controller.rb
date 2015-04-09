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
    if @punchcard.checkin.present?
      check = @punchcard.checkin.strftime("%Y-%m-%d")
      exist = Punchcard.where("company_id = ? and project_id = ? and worker_id = ? and (checkin like ? or checkout like ?)", @punchcard.company_id, @punchcard.project_id, @punchcard.worker_id, "#{check}%", "#{check}%")
      if exist.present?
        if exist.count == 1
          exist.checkin = @punchcard.checkin
          exist.checkin_location = @punchcard.checkin_location
          if @punchcard.checkout.present?
            exist.checkout = @punchcard.checkout
            exist.checkout_location = @punchcard.checkout_location
          end
          @punchcard = exist
        else
          # should not happen
        end
      end
    elsif @punchcard.checkout.present?
      check = @punchcard.checkout.strftime("%Y-%m-%d")
      exist = Punchcard.where("company_id = ? and project_id = ? and worker_id = ? and (checkin like ? or checkout like ?)", @punchcard.company_id, @punchcard.project_id, @punchcard.worker_id, "#{check}%", "#{check}%")
      if exist.present?
        if exist.count == 1
          exist.checkout = @punchcard.checkout
          exist.checkout_location = @punchcard.checkout_location
          if @punchcard.checkin.present?
            exist.checkin = @punchcard.checkin
            exist.checkin_location = @punchcard.checkin_location
          end
          @punchcard = exist
        else
          # should not happen
        end
      end
    end

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