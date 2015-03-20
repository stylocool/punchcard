class Api::WorkersController < ApplicationController
  before_filter :authenticate_user_from_token!
  respond_to :json

  def show
    @worker = Worker.find_by_work_permit(params[:id])
  end

  def show_by_work_permit
    @worker = Worker.find_by_work_permit(params[:id])

    if @worker.present?

    else
      usercompany = UserCompany.where(:user_id => current_user.id).first
      company = Company.find(usercompany.company_id)

      # create new worker if work permit not found
      @worker = Worker.new()
      @worker.name = "UNKNOWN"
      @worker.race = ""
      @worker.gender = ""
      @worker.nationality = ""
      @worker.contact = ""
      @worker.work_permit = params[:id]
      @worker.worker_type = "worker"
      @worker.company_id = company.id
      @worker.save
    end
  end
end