class BlacklistedToken < ApplicationRecord
  # Clean up expired tokens
  def self.cleanup
    where('exp < ?', Time.current).delete_all
  end

  # Check if token is blacklisted
  def self.blacklisted?(jti)
    exists?(jti: jti)
  end
end
