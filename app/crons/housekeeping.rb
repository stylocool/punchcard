class Housekeeping
  def self.clear_expired_sessions
    Session.where('updated_at < ?', 30.minutes.ago).delete_all
  end
end