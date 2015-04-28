require 'rails_helper'

RSpec.describe Project, type: :model do

  it "is invalid without a name" do
    project = Project.new(name: nil)
    project.valid?
    expect(project.errors[:name]).to include("can't be blank")
  end
  it "is invalid without a location" do
    project = Project.new(location: nil)
    project.valid?
    expect(project.errors[:location]).to include("can't be blank")
  end
  it "is invalid without a company" do
    project = Project.new(company_id: nil)
    project.valid?
    expect(project.errors[:company_id]).to include("can't be blank")
  end

end