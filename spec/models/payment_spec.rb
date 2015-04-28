require 'rails_helper'

RSpec.describe Payment, type: :model do

  it 'is invalid without total workers' do
    payment = Payment.new(total_workers: nil)
    payment.valid?
    expect(payment.errors[:total_workers]).to include("can't be blank")
  end
  it 'is invalid if total workers is < 1' do
    payment = Payment.new(total_workers: 0)
    payment.valid?
    expect(payment.errors[:total_workers]).to include('must be greater than or equal to 1')
  end

end