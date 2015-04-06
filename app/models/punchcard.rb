class Punchcard < ActiveRecord::Base
  has_paper_trail :on => [:create, :update, :destroy]

  cattr_accessor :work

  belongs_to :worker
  belongs_to :project
  belongs_to :company
end