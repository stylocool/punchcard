require 'rails_helper'

RSpec.describe License, type: :model do

  it "is invalid without a name" do
    license = License.new(name: nil)
    license.valid?
    expect(license.errors[:name]).to include("can't be blank")
  end
  it "is invalid without cost per worker" do
    license = License.new(cost_per_worker: nil)
    license.valid?
    expect(license.errors[:cost_per_worker]).to include("can't be blank")
  end
  it "is invalid without total workers" do
    license = License.new(total_workers: nil)
    license.valid?
    expect(license.errors[:total_workers]).to include("can't be blank")
  end
  it "is invalid if cost per worker is < 1" do
    license = License.new(cost_per_worker: 0)
    license.valid?
    expect(license.errors[:cost_per_worker]).to include("must be greater than or equal to 1")
  end
  it "is invalid if total workers is < 1" do
    license = License.new(total_workers: 0)
    license.valid?
    expect(license.errors[:total_workers]).to include("must be greater than or equal to 1")
  end

end