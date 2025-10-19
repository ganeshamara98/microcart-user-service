class JwtService
  # Use Rails secret key base from credentials or fallback
  SECRET_KEY = Rails.application.credentials.dig(:jwt_secret)

  def self.encode(payload, exp = 1.hour.from_now)
    payload[:exp] = exp.to_i
    payload[:jti] = SecureRandom.uuid  # Add unique JWT ID
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
    token_data = HashWithIndifferentAccess.new(decoded)

    # Check if token is blacklisted
    if BlacklistedToken.blacklisted?(token_data[:jti])
      return nil
    end

    token_data
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError => e
    nil
  end

  # Extract JTI from token without validation
  def self.get_jti(token)
    begin
      decoded = JWT.decode(token, SECRET_KEY, false)[0]
      decoded['jti']
    rescue
      nil
    end
  end
end
