class PayrollWorkItem
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :punchcard, :date, :total_hours, :normal_work_hours, :overtime_work_hours, :amount, :amount_normal, :amount_overtime, :amount_deduction

  #def initialize(punchcard)
  #  @punchcard = punchcard
  #  calculate
  #end

  def calculate
    company = punchcard.company
    project = punchcard.project
    worker = punchcard.worker
    company_setting = punchcard.company.company_setting

    checkin = punchcard.checkin
    checkout = punchcard.checkout

    seconds_diff = (checkout - checkin).to_i.abs
    hours = seconds_diff / 3600
    seconds_diff -= hours * 3600
    minutes = seconds_diff / 60
    seconds_diff -= minutes * 60
    seconds = seconds_diff

    @total_hours = hours + minutes/60

    # work hours
    if hours > company_setting.working_hours.to_i
      @normal_work_hours = company_setting.working_hours.to_i
      hours -= company_setting.working_hours.to_i
      @overtime_work_hours = hours + minutes / 60
    else
      @normal_work_hours = hours + minutes / 60
    end

    @amount_normal = @normal_work_hours.to_i * company_setting.rate.to_i
    @amount_overtime = @overtime_work_hours.to_i * company_setting.overtime_rate.to_i
    @amount = @amount_normal + @amount_overtime

    @amount_deduction = 0
    if @punchcard.cancel_pay
      @amount_deduction = @amount
      @amount = 0
    end

    if @punchcard.fine.to_i > 0
      @amount = @punchcard.fine.to_i
      @amount_deduction += @punchcard.fine.to_i
    end

    #if @amount < 0
    #  @amount = 0
    #end

  end

end