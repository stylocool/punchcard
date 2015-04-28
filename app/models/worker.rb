class Worker < ActiveRecord::Base
  has_paper_trail on: [:create, :update, :destroy]

  GENDERS = ['Male', 'Female']
  RACES = ['Chinese', 'Indian', 'Malay', 'Others']
  WORKER_TYPES = ['Worker', 'Supervisor']

  belongs_to :company
  has_many :punchcards, dependent: :destroy

  # validations
  validates :name, :contact, :work_permit, :basic_pay, presence: true
  validates_uniqueness_of :name, :contact, :work_permit
end