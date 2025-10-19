class HealthController < ApplicationController
  skip_before_action :authenticate_request

  def check
    render json: {
      status: 'OK',
      timestamp: Time.current,
      service: 'user-service'
    }
  end
end
