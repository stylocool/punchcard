class Api::WorkersController < ApplicationController
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

  def show
    @worker = Worker.find_by_work_permit(params[:id])
  end

  def show_by_work_permit
    @worker = Worker.find_by_work_permit(params[:id])

    if @worker.present?

    else
      usercompany = UserCompany.where(user_id: current_user.id).first
      company = Company.find(usercompany.company_id)

      # create new worker if work permit not found
      @worker = Worker.new()
      @worker.name = "UNKNOWN"
      @worker.race = ""
      @worker.gender = ""
      @worker.nationality = ""
      @worker.contact = "UNKNOWN"
      @worker.work_permit = params[:id]
      @worker.worker_type = "Worker"
      @worker.company_id = company.id
      @worker.basic_pay = 20
      @worker.save
    end
  end
end