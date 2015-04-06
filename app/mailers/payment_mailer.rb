class PaymentMailer < ActionMailer::Base
  default from: 'sales.punchcard@gmail.com"'

  def send_payment(payment)
    @payment = payment

    mail(
        to: payment.company.email,
        subject: "Payment for #{payment.months_of_service} months of PunchCard service for #{payment.company.name}"
    )
  end

end
