class Punchcard < ActiveRecord::Base
	belongs_to :worker
  belongs_to :project
  belongs_to :company
end