class RegistrationsController < ApplicationController

  skip_before_action :authorize!, only: [:create]

  def create
    STATSD.time("token.create") do
      user = User.new(user_params.merge(provider: 'standard'))
      user.save!
      STATSD.increment "token.create.count"
      render json: serializer(user), status: :created
    rescue
      STATSD.increment "token.create.error.count"
      render json:  model_unprocessable(user.errors.messages), status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:data).require(:attributes).permit(:login, :password).to_h.symbolize_keys
  end

  def serializer(obj)
    UserSerializer.new(obj).serialized_json
  end
end