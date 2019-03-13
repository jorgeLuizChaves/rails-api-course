class UserAuthentication
  class UserAuthenticationError < StandardError; end

  attr_reader :user, :authentication

  def initialize(code: nil, login: nil, password: nil)
    @authentication = if code.present?
      Oauth.new(code)
    else
      Standard.new(login, password)
    end
  end

  def perform
    authentication.perform
  end

  def access_token
    authentication.access_token
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

  def prepare_user
    @user = if User.exists?(login: user_data[:login])
              User.find_by(login: user_data[:login])
            else
              User.create(user_data)
            end
  end
end