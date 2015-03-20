class Worker < ActiveRecord::Base
  GENDERS = ["Male", "Female"]
  RACES = ["Chinese", "Indian", "Malay", "Others"]
  WORKER_TYPES = ["Worker", "Supervisor"]
  belongs_to :company
end