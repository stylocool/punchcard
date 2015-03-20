class Company < ActiveRecord::Base
	COMPANY_STATUSES = ["Active", "Pending", "Suspended"]

  has_one :license, dependent: :destroy
  has_one :company_setting, dependent: :destroy
  has_many :workers, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :punchcards, dependent: :destroy
  #has_many :usercompanies, dependent: :destroy
end