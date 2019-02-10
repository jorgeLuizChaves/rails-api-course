class AccessTokensController < ApplicationController

  rescue_from UserAuthentication::UserAuthenticationError, with: :handle_user_authentication_error

  def create
    user_authentication = UserAuthentication.new(params[:code])
    user_authentication.perform
    render json: AccessTokenSerializer.new(user_authentication.access_token).serialized_json, status: :created
  end

  def destroy
    raise AuthorizationError
  end

  private
  def serializer
    AccessTokenSerializer
  end
end
