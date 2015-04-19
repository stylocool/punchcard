class Punchcard < ActiveRecord::Base
  has_paper_trail :on => [:create, :update, :destroy]

  belongs_to :worker
  belongs_to :project
  belongs_to :company

  attr_accessor :calculated, :total_hours, :normal_work_hours, :overtime_work_hours, :amount, :amount_normal, :amount_overtime, :amount_deduction, :remarks,
                :total_work_minutes, :normal_work_minutes, :overtime_work_minutes, :amount_minutes, :amount_normal_minutes, :amount_overtime_minutes, :amount_deduction_minutes

  @calculated = 0

  def calculate

    unless @calculated == 1

      @calculated = 1

      @remarks = ""
      cal_checkin = checkin
      cal_checkout = checkout

      unless cal_checkin.present?
        # check leave
        if self.leave.present?
          if self.leave == 'Leave (AM)' || leave == 'MC'
            # set checkin to 1pm
            append_remarks(leave + ".")
            cal_checkin = cal_checkout.change(hour: 13, minute: 0, second: 0)
          else
            # no other valid reason
            cal_checkin = cal_checkout
          end
        else
          # awol so set checkin to be 1pm
          append_remarks("Checkin not available.")
          cal_checkin = cal_checkout
        end
      end

      unless cal_checkout.present?
        # check leave
        if self.leave.present?
          if self.leave == 'Leave (PM)' || leave == 'MC'
            # set checkin to 1pm
            append_remarks(leave + ".")
            cal_checkout = cal_checkin.change(hour: 13, minute: 0, second: 0)
          else
            # no other valid reason
            cal_checkout = cal_checkin
          end
        else
          # awol
          append_remarks("Checkout not available.")
          cal_checkout = cal_checkin
        end
      end

      if cal_checkin > cal_checkout
        append_remarks('Checkin is later than Checkout.')
      end

      seconds_diff = (cal_checkout - cal_checkin).to_i.abs
      hours = seconds_diff / 3600
      seconds_diff -= hours * 3600
      minutes = seconds_diff / 60
      seconds_diff -= minutes * 60
      seconds = seconds_diff

      # round up seconds
      if seconds >= 30
        seconds = 0
        minutes += 1
      end

      if minutes >= 60
        hours += 1
        minutes -= 60
      end

      lunch_hour = cal_checkin.hour < 11 # lunch hour is deducted if checkin is before 11am
      dinner_hour = cal_checkin.hour < 22 && cal_checkout.hour >= 22 # dinner hour is deducted if checkout is after or equals to 10pm

      #hours += minutes/60
      total_minutes = hours * 60 + minutes

      # check lunch hour
      if company.company_setting.lunch_hour && lunch_hour
        #if hours > 0
        if total_minutes > 0
          append_remarks("Lunch hour deduction.")
          #hours -= 1
          total_minutes -= 60
        end
      end

      # check dinner hour
      if company.company_setting.dinner_hour && dinner_hour
        #if hours > 0
        if total_minutes > 0
          append_remarks("Dinner hour deduction.")
          #hours -= 1
          total_minutes -= 60
        end
      end

      #@total_hours = hours
      @total_work_minutes = total_minutes

      # work hours/minutes
      #if hours > self.company.company_setting.working_hours.to_f
      if total_minutes > self.company.company_setting.working_hours.to_i * 60
        #@normal_work_hours = self.company.company_setting.working_hours.to_f
        @normal_work_minutes = self.company.company_setting.working_hours.to_i * 60
        #hours -= self.company.company_setting.working_hours.to_f
        total_minutes -= self.company.company_setting.working_hours.to_i * 60
        #@overtime_work_hours = hours
        @overtime_work_minutes = total_minutes
      else
        #@normal_work_hours = hours
        @normal_work_minutes = total_minutes
        #@overtime_work_hours = 0
        @overtime_work_minutes = 0
      end

      #hour_rate = self.worker.basic_pay.to_f / self.company.company_setting.working_hours.to_f
      minute_rate = (self.worker.basic_pay.to_f / (self.company.company_setting.working_hours.to_f * 60))

      #overtime_rate = hour_rate * self.company.company_setting.overtime_rate.to_f
      overtime_rate_minute = minute_rate * self.company.company_setting.overtime_rate.to_f

      #if @normal_work_hours >= self.company.company_setting.working_hours.to_f
      #  @amount_normal = self.worker.basic_pay.to_f
      #else
      #  @amount_normal = @normal_work_hours.to_f * hour_rate
      #end

      if @normal_work_minutes >= self.company.company_setting.working_hours.to_i * 60
        @amount_normal_minutes = self.worker.basic_pay.to_f
      else
        @amount_normal_minutes = @normal_work_minutes.to_f * minute_rate
      end

      #@amount_overtime = @overtime_work_hours.to_f * overtime_rate
      @amount_overtime_minutes = @overtime_work_minutes.to_f * overtime_rate_minute

      #@amount = @amount_normal + @amount_overtime
      @amount_minutes = @amount_normal_minutes + @amount_overtime_minutes

      #@amount_deduction = 0
      @amount_deduction_minutes = 0
      if self.cancel_pay
        #@amount_deduction = @amount
        @amount_deduction_minutes = @amount_minutes
        #@amount = 0
        @amount_minutes = 0
      end

      if self.fine.to_f > 0
        #@amount -= self.fine.to_f
        @amount_minutes -= self.fine.to_f
        #@amount_deduction += self.fine.to_f
        @amount_deduction_minutes += self.fine.to_f
      end

      #if @amount < 0
      #  @amount = 0
      #end

    end

    #@amount
    @amount_minutes
  end

  def append_remarks(msg)
    if @remarks.length > 0
      @remarks = @remarks + ' ' + msg
    else
      @remarks = msg
    end
    #@remarks
  end
end