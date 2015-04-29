class PaymentMailer < ActionMailer::Base
  
  def send_payment(payment)
    @payment = payment

    mail(
        from: 'sales.punchcard@gmail.com',
        to: payment.company.email,
        subject: "Payment for #{payment.months_of_service} months of Punch service for #{payment.company.name}"
    )
  end

end
