require 'rails_helper'

RSpec.describe Worker, type: :model do

  it "is invalid without a name" do
    worker = Worker.new(name: nil, contact: nil, work_permit: nil, basic_pay: nil)
    worker.valid?
    expect(worker.errors[:name]).to include("can't be blank")
  end

  it "is invalid without a contact" do
    worker = Worker.new(name: nil, contact: nil, work_permit: nil, basic_pay: nil)
    worker.valid?
    expect(worker.errors[:contact]).to include("can't be blank")
  end

  it "is invalid without a work permit" do
    worker = Worker.new(name: nil, contact: nil, work_permit: nil, basic_pay: nil)
    worker.valid?
    expect(worker.errors[:work_permit]).to include("can't be blank")
  end

  it "is invalid without basic pay" do
    worker = Worker.new(name: nil, contact: nil, work_permit: nil, basic_pay: nil)
    worker.valid?
    expect(worker.errors[:basic_pay]).to include("can't be blank")
  end

  it "is invalid if name, contact and work_permit is not unique" do
    Worker.create(name: 'Test', contact: '1', work_permit: '1', basic_pay: 20)
    worker = Worker.new(name: 'Test', contact: '1', work_permit: '1', basic_pay: 20)
    worker.valid?
    expect(worker.errors[:name]).to include("has already been taken")
    expect(worker.errors[:contact]).to include("has already been taken")
    expect(worker.errors[:work_permit]).to include("has already been taken")
  end

end