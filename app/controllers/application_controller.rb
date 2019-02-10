class ApplicationController < ActionController::API


  private

  def handle_user_authentication_error
    error = {
        "status" => "401",
        "source" => { "pointer": "/code" },
        "title" => "Authentication code is invalid",
        "detail" => "You must provide valid code in order to exchange it for token."
    }
    render json: {'errors' => [error]},
           status: :unauthorized
  end
end
