class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: [:login, :register]
  before_action :authenticate_request, only: [:logout, :me]

  # POST /auth/register
  def register
    user = User.new(user_params)

    if user.save
      token = JwtService.encode(user_id: user.id)
      expires_at = 1.hour.from_now

      render json: {
        user: user_json(user),
        token: token,
        expires_at: expires_at
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /auth/login
  def login
    user = User.find_by(email: login_params[:email]&.downcase)

    if user&.authenticate(login_params[:password])
      token = JwtService.encode(user_id: user.id)
      expires_at = 1.hour.from_now

      render json: {
        user: user_json(user),
        token: token,
        expires_at: expires_at
      }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  # POST /auth/logout
  def logout
    # Get the JTI from the current token and blacklist it
    token = request.headers['Authorization']&.split(' ')&.last

    if token
      jti = JwtService.get_jti(token)
      decoded_token = JwtService.decode(token) # This checks if already blacklisted

      if jti && decoded_token
        # Blacklist the token
        BlacklistedToken.create!(
          jti: jti,
          exp: Time.at(decoded_token[:exp]),
          user_id: current_user.id
        )

        # Clean up old blacklisted tokens
        BlacklistedToken.cleanup

        render json: { message: 'Successfully logged out' }, status: :ok
      else
        render json: { error: 'Invalid or already expired token' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'No token provided' }, status: :unprocessable_entity
    end
  end

  # GET /auth/me
  def me
    render json: { user: user_json(current_user) }, status: :ok
  end

  private

  def user_params
    if params[:authentication].present?
      params.require(:authentication).permit(:email, :password, :first_name, :last_name)
    else
      params.permit(:email, :password, :first_name, :last_name)
    end
  end

  def login_params
    if params[:authentication].present?
      params.require(:authentication).permit(:email, :password)
    else
      params.permit(:email, :password)
    end
  end

  def user_json(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
