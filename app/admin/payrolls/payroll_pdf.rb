class PayrollPdf < Prawn::Document

  def initialize
    super(size: 'A5', page_layout: :landscape)
  end

  def generate(worker, period, start_date, stop_date, year, month, days, view)
    punchcards = Punchcard.where(worker_id: worker.id, checkin: start_date.utc..stop_date.utc)
    calculator = PayrollCalculator.new(punchcards, year, month, days)

    company(worker)
    payroll_message(period)
    worker_table(worker, get_payment_date(period), calculator.days_worked)
    payroll_table(calculator.amount, calculator.amount_normal, calculator.amount_overtime, calculator.amount_deduction, view)
    signature_table
  end

  def get_payment_date(period)
    next_month = period + 1.month
    next_month.strftime('5 %B %Y')
  end

  def generate_and_merge(workers, period, start_date, stop_date, year, month, days, view)
    index = 0
    workers.each do |worker|
      punchcards = Punchcard.where(worker_id: worker.id, checkin: start_date.utc..stop_date.utc)
      calculator = PayrollCalculator.new(punchcards, year, month, days)

      company(worker)
      payroll_message(period)
      worker_table(worker, get_payment_date(period), calculator.days_worked)
      payroll_table(calculator.amount, calculator.amount_normal, calculator.amount_overtime, calculator.amount_deduction, view)
      signature_table

      index += 1
      if index < workers.length
        start_new_page
      end
    end
  end

  def company(worker)
    text worker.company.name, size: 24, style: :bold, align: :center
    text worker.company.address, size: 12, align: :center

    #logopath =  "#{Rails.root}/public" + @worker.company.logo.url(:original)
    # remove ?
    #image logopath.partition('?')[0], width: 100, height: 100, at: [570, 570]
  end

  def payroll_message(period)
    move_down 10
    text 'Payslip for the period of ' + period.strftime('%B %Y'), align: :center, size: 18
  end

  def worker_table(worker, payment_date, days_worked)
    move_down 10
    table worker_details(worker, payment_date, days_worked), position: :center, width: 500 do
      cells.border_width = 0
      columns(1).align = :center
      columns(4).align = :center
      self.header = true
      self.column_widths = {0 => 50, 1 => 20, 2 => 180, 3 => 80, 4 => 20, 5 => 150}
    end
  end

  def worker_details(worker, payment_date, days_worked)
    [
        ['Date', ':', payment_date, '', '', ''],
        ['Name', ':', worker.name, 'Work Permit', ':', worker.work_permit],
        ['Trade', ':', worker.trade, 'No. of Days Worked', ':', days_worked]
    ]
  end

  def payroll_table(amount, amount_normal, amount_overtime, amount_deduction, view)
    move_down 10
    table payroll_details(amount, amount_normal, amount_overtime, amount_deduction, view), position: :center, width: 500, cell_style: { inline_format: true } do
      cells[0, 0].borders = [:top, :bottom, :left, :right]
      cells[0, 1].borders = [:top, :bottom, :left, :right]

      cells[1, 0].borders = [:top, :bottom, :left, :right]
      cells[1, 1].borders = [:top, :bottom, :left, :right]

      cells[2, 0].borders = [:top, :bottom, :left, :right]
      cells[2, 1].borders = [:top, :bottom, :left, :right]

      cells[3, 0].borders = [:top, :bottom, :left, :right]
      cells[3, 1].borders = [:top, :bottom, :left, :right]

      cells[4, 0].borders = [:top, :bottom, :left, :right]
      cells[4, 1].borders = [:top, :bottom, :left, :right]

      cells[5, 0].borders = [:top, :bottom, :left, :right]
      cells[5, 1].borders = [:top, :bottom, :left, :right]

      cells[6, 0].borders = [:top, :bottom, :left, :right]
      cells[6, 1].borders = [:top, :bottom, :left, :right]

      cells[7, 0].borders = [:top, :bottom, :left, :right]
      cells[7, 1].borders = [:top, :bottom, :left, :right]

      cells[8, 0].borders = [:top, :bottom, :left, :right]
      cells[8, 1].borders = [:top, :bottom, :left, :right]

      cells[9, 0].borders = [:top, :bottom, :left, :right]
      cells[9, 1].borders = [:top, :bottom, :left, :right]

      cells[10, 0].borders = [:top, :bottom, :left, :right]
      cells[10, 1].borders = [:top, :bottom, :left, :right]

      self.header = true
      columns(1).align = :center
      self.column_widths = { 0 => 250, 1 => 250 }
    end
  end

  def payroll_details(amount, amount_normal, amount_overtime, amount_deduction, view)
    [
      ['<b>Earnings</b>', '<b>Amount</b>'],
      ['Basic Pay', currency(view, amount_normal)],
      ['Overtime', currency(view, amount_overtime)],
      [' ',' '],
      ['Less: Deduction', currency(view, amount_deduction)],
      [' ',' '],
      ['Total Earnings', currency(view, amount_normal + amount_overtime)],
      [' ',' '],
      ['Allowance/Claim', ''],
      [' ',' '],
      [' ',' ']
    ]
  end

  def signature_table
    move_down 50
    table signature_details, position: :center, width: 500 do

      cells[0, 0].borders = [:bottom]
      cells[0, 1].border_width = 0
      cells[0, 2].borders = [:bottom]
      cells[0, 3].border_width = 0

      cells[1, 0].border_width = 0
      cells[1, 1].border_width = 0
      cells[1, 2].border_width = 0
      cells[1, 3].border_width = 0

      self.header = true
      self.column_widths = {0 => 125, 1 => 125, 2 => 125, 3 => 125}
    end
  end

  def signature_details
    [
        ['','','',''],
        ['Employer\'s Signature', '', 'Employee\'s Signature', '']
    ]
  end

  def currency(view, num)
    view.number_to_currency(num)
  end
end
