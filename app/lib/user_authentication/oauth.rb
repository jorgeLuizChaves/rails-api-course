class UserAuthentication::Oauth < UserAuthentication
  class UserAuthenticationError < StandardError; end

  attr_reader :user

  def initialize(code = nil)
    @code = code
  end

  def perform
    raise UserAuthentication::Oauth::UserAuthenticationError if code.blank?
    raise UserAuthentication::Oauth::UserAuthenticationError if token.try(:error).present?

    prepare_user
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