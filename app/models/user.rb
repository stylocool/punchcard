class User < ActiveRecord::Base
  has_paper_trail :on => [:create, :update, :destroy]
  before_create :set_default_role

  # Include default users modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  cattr_accessor :current_company

  before_save :ensure_authentication_token!

  def role?(r)
    role.include? r.to_s
  end

  def generate_secure_token_string
    SecureRandom.urlsafe_base64(25).tr('lIO0', 'sxyz')
  end

  # Sarbanes-Oxley Compliance: http://en.wikipedia.org/wiki/Sarbanes%E2%80%93Oxley_Act
  def password_complexity
    if password.present? and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W]).+/)
      errors.add :password, "must include at least one of each: lowercase letter, uppercase letter, numeric digit, special character."
    end
  end

  def password_presence
    password.present? && password_confirmation.present?
  end

  def password_match
    password == password_confirmation
  end

  def ensure_authentication_token!
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
      self.authentication_token_expiry = 1.day.from_now
    else
      # check expiry
      if (self.authentication_token_expiry.present?)
        if (self.authentication_token_expiry < Time.now)
          # expired
          self.authentication_token = generate_authentication_token
          self.authentication_token_expiry = 1.day.from_now
        end
      else
        self.authentication_token = generate_authentication_token
        self.authentication_token_expiry = 1.day.from_now
      end
    end
  end

  def generate_authentication_token
    loop do
      token = generate_secure_token_string
      break token unless User.where(authentication_token: token).first
    end
  end

  def reset_authentication_token!
    self.authentication_token = generate_authentication_token
  end

  private
  def set_default_role
    unless self.role.present?
      self.role = 'Administrator'
    end
  end


end
