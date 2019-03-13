class AccessTokensController < ApplicationController
  
  skip_before_action :authorize!, only: [:create]

  def create
    user_authentication = UserAuthentication.new(authentication_params)
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

  def authentication_params
    (standard_auth_params || params.permit(:code)).to_h.symbolize_keys
  end

  def standard_auth_params
    params.dig(:data, :attributes)&.permit(:login, :password)
  end
end
