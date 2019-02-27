class UserAuthentication
  class UserAuthenticationError < StandardError; end

  attr_reader :user, :access_token, :authentication

  def initialize(code = nil)
    @authentication = Oauth.new(code)
  end

  def perform
    authentication.perform
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