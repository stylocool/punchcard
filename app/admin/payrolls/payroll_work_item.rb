class PayrollWorkItem
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :punchcard, :date, :total_hours, :normal_work_hours, :overtime_work_hours, :amount, :amount_normal, :amount_overtime, :amount_deduction, :remarks

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

    @remarks = ""

    unless checkin.present?
      # check leave
      if punchcard.leave.present?
        if punchcard.leave == 'Leave (AM)' || punchcard.leave == 'MC'
          # set checkin to 1pm
          @remarks = append_remarks(@remarks, punchcard.leave + ".")
          checkin = checkout.change(hour: 13, minute: 0, second: 0)
        else
          # no other valid reason
          checkin = checkout
        end
      else
        # awol so set checkin to be 1pm
        @remarks = append_remarks(@remarks, "Checkin not available.")
        checkin = checkout
      end
    end

    unless checkout.present?
      # check leave
      if punchcard.leave.present?
        if punchcard.leave == 'Leave (PM)' || punchcard.leave == 'MC'
          # set checkin to 1pm
          @remarks = append_remarks(@remarks, punchcard.leave + ".")
          checkout = checkin.change(hour: 13, minute: 0, second: 0)
        else
          # no other valid reason
          checkout = checkin
        end
      else
        # awol
        @remarks = append_remarks(@remarks, "Checkout not available.")
        checkout = checkin
      end
    end

    seconds_diff = (checkout - checkin).to_i.abs
    hours = seconds_diff / 3600
    seconds_diff -= hours * 3600
    minutes = seconds_diff / 60
    seconds_diff -= minutes * 60
    seconds = seconds_diff

    if seconds > 30
      minutes = minutes + 1
    end

    if minutes >= 60
      hours = hours + 1
      minutes = minutes - 60
    end

    lunch_hour = checkin.hour < 11
    dinner_hour = checkout.hour >= 22

    hours = hours + minutes/60

    if company_setting.lunch_hour && lunch_hour
      if hours > 0
        @remarks = append_remarks(@remarks, "Lunch hour deduction.")
        hours = hours - 1
      end
    end
    if company_setting.dinner_hour && dinner_hour
      if hours > 0
        @remarks = append_remarks(@remarks, "Dinner hour deduction.")
        hours = hours - 1
      end
    end

    @total_hours = hours

    # work hours
    if hours > company_setting.working_hours.to_f
      @normal_work_hours = company_setting.working_hours.to_f
      hours -= company_setting.working_hours.to_f
      @overtime_work_hours = hours
    else
      @normal_work_hours = hours
      @overtime_work_hours = 0
    end

    hour_rate = company_setting.rate.to_f / company_setting.working_hours.to_f
    overtime_rate = hour_rate * company_setting.overtime_rate.to_f

    if @normal_work_hours == company_setting.working_hours.to_f
      @amount_normal = company_setting.rate.to_f
    else
      @amount_normal = @normal_work_hours.to_f * hour_rate
    end

    @amount_overtime = @overtime_work_hours.to_f * overtime_rate
    @amount = @amount_normal + @amount_overtime

    @amount_deduction = 0
    if @punchcard.cancel_pay
      @amount_deduction = @amount
      @amount = 0
    end

    if @punchcard.fine.to_f > 0
      @amount -= @punchcard.fine.to_f
      @amount_deduction += @punchcard.fine.to_f
    end

    #if @amount < 0
    #  @amount = 0
    #end

  end

  def append_remarks(remarks, msg)
    if remarks.length > 0
      remarks = remarks + ' ' + msg
    else
      remarks = msg
    end
    remarks
  end

end