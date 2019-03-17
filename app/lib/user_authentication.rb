class UserAuthentication
  class UserAuthenticationError < StandardError; end

  attr_reader :access_token, :authentication

  def initialize(code: nil, login: nil, password: nil)
    @authentication = if code.present?
      Oauth.new(code)
    elsif login.present? && password.present?
      Standard.new(login, password)
    else
      raise UserAuthenticationError
    end
  end

  def perform
    authentication.perform
    set_access_token
  end

  def user
    authentication.user
  end

  private
  attr_reader :code

  def client
    @client ||= Octokit::Client.new(
        client_id: ENV['GITHUB_CLIENT_ID'],
        client_secret: ENV['GITHUB_CLIENT_SECRET'])
  end

  def user_data
    @user_data ||= Octokit::Client.new(
        access_token: code
    ).user.to_h.slice(:login, :avatar_url, :url, :name
    ).merge(provider:'github')
  end

  def token
    @token ||= client.exchange_code_for_token(code)
  end

  def set_access_token
    @access_token = if user.access_token.present?
      user.access_token
    else
      user.create_access_token
    end
  end
end