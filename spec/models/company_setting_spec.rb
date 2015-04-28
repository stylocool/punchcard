require 'rails_helper'

RSpec.describe CompanySetting, type: :model do

  it "is invalid without a name" do
    company_setting = CompanySetting.new(name: nil)
    company_setting.valid?
    expect(company_setting.errors[:name]).to include("can't be blank")
  end
  it "is invalid without a distance check" do
    company_setting = CompanySetting.new(distance_check: nil)
    company_setting.valid?
    expect(company_setting.errors[:distance_check]).to include("can't be blank")
  end
  it "is invalid without an overtime rate" do
    company_setting = CompanySetting.new(overtime_rate: nil)
    company_setting.valid?
    expect(company_setting.errors[:overtime_rate]).to include("can't be blank")
  end
  it "is invalid without a company" do
    company_setting = CompanySetting.new(company_id: nil)
    company_setting.valid?
    expect(company_setting.errors[:company_id]).to include("can't be blank")
  end
  it "is invalid without working hours" do
    company_setting = CompanySetting.new(working_hours: nil)
    company_setting.valid?
    expect(company_setting.errors[:working_hours]).to include("can't be blank")
  end
  it "is invalid if overtime rate is < 1" do
    company_setting = CompanySetting.new(overtime_rate: 0)
    company_setting.valid?
    expect(company_setting.errors[:overtime_rate]).to include("must be greater than or equal to 1")
  end
  it "is invalid if working hours is < 1" do
    company_setting = CompanySetting.new(working_hours: 0)
    company_setting.valid?
    expect(company_setting.errors[:working_hours]).to include("must be greater than or equal to 1")
  end
  it "is invalid if distance check is < 0" do
    company_setting = CompanySetting.new(distance_check: -1)
    company_setting.valid?
    expect(company_setting.errors[:distance_check]).to include("must be greater than or equal to 0")
  end

end