class Company < ActiveRecord::Base
  has_paper_trail :on => [:create, :update, :destroy]

	COMPANY_STATUSES = ["Active", "Pending", "Suspended"]

  has_one :license, dependent: :destroy
  has_one :company_setting, dependent: :destroy
  has_one :user_company, dependent: :destroy

  has_many :workers, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :punchcards, dependent: :destroy

  has_attached_file :logo,
                    :path => ":rails_root/public/system/:attachment/:id/:basename_:style.:extension",
                    :url => "/system/:attachment/:id/:basename_:style.:extension",
                    :styles => {
                        :thumb    => ['100x100#',  :jpg, :quality => 70],
                        :preview  => ['480x480#',  :jpg, :quality => 70],
                        :large    => ['600>',      :jpg, :quality => 70],
                        :retina   => ['1200>',     :jpg, :quality => 30]
                    },
                    :convert_options => {
                        :thumb    => '-set colorspace sRGB -strip',
                        :preview  => '-set colorspace sRGB -strip',
                        :large    => '-set colorspace sRGB -strip',
                        :retina   => '-set colorspace sRGB -strip -sharpen 0x0.5'
                    }


  # validations
  validates :name, :address, :email, :telephone, presence: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates_format_of :telephone, :with => /([6,8,9])\d{7}/
  validates :total_workers, presence: true, numericality: { only_integer: true, :greater_than => 0 }
  validates_attachment :logo,
                       :presence => true,
                       :size => { :in => 0..2.megabytes },
                       :content_type => { :content_type => /^image\/(jpeg|png|gif|tiff)$/ }


end