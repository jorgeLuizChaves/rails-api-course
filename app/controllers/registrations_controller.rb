class RegistrationsController < ApplicationController

  skip_before_action :authorize!, only: [:create]

  def create
    user = User.new(user_params.merge(provider: 'standard'))
    user.save!
    render json: serializer(user), status: :created
  rescue
    render json:  model_unprocessable(user.errors.messages), status: :unprocessable_entity
  end

  private

  def user_params
    params.require(:data).require(:attributes).permit(:login, :password).to_h.symbolize_keys
  end

  def serializer(obj)
    UserSerializer.new(obj).serialized_json
  end
end