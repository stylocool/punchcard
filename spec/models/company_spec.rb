require 'rails_helper'

RSpec.describe Company, type: :model do

  it "is invalid without a name" do
    company = Company.new(name: nil)
    company.valid?
    expect(company.errors[:name]).to include("can't be blank")
  end
  it "is invalid without an address" do
    company = Company.new(address: nil)
    company.valid?
    expect(company.errors[:address]).to include("can't be blank")
  end
  it "is invalid without an email" do
    company = Company.new(email: nil)
    company.valid?
    expect(company.errors[:email]).to include("can't be blank")
  end
  it "is invalid without a telephone" do
    company = Company.new(telephone: nil)
    company.valid?
    expect(company.errors[:telephone]).to include("can't be blank")
  end
  it "is invalid without a logo" do
    company = Company.new(logo: nil)
    company.valid?
    expect(company.errors[:logo]).to include("can't be blank")
  end
  it "is invalid without total workers" do
    company = Company.new(total_workers: nil)
    company.valid?
    expect(company.errors[:total_workers]).to include("can't be blank")
  end

end