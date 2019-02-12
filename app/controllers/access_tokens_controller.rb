class AccessTokensController < ApplicationController

  rescue_from UserAuthentication::UserAuthenticationError, with: :handle_user_authentication_error

  skip_before_action :authorize!, only: [:create]

  def create
    user_authentication = UserAuthentication.new(params[:code])
    user_authentication.perform
    render json: AccessTokenSerializer.new(user_authentication.access_token).serialized_json, status: :created
  end

  def destroy
    current_user.access_token.destroy
  end

  private
  def serializer
    AccessTokenSerializer
  end
end
