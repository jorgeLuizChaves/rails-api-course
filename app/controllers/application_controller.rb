class ApplicationController < ActionController::API

  class AuthorizationError < StandardError; end

  rescue_from UserAuthentication::UserAuthenticationError, with: :handle_user_authentication_error
  rescue_from AuthorizationError, with: :handle_authorization_error

  private

  def handle_user_authentication_error
    error = {
        "status" => "401",
        "source" => { "pointer": "/code" },
        "title"  => "Authentication code is invalid",
        "detail" => "You must provide valid code in order to exchange it for token."
    }
    render json: {'errors' => [error]},
           status: :unauthorized
  end

  def handle_authorization_error
    error = {
        "status": "403",
        "source": { "pointer": "/headers/authorization" },
        "title":  "Not authorized",
        "detail": "You have no right access to this resource."
    }
    render json: {'errors' => [error]}, status: :forbidden
  end
end
