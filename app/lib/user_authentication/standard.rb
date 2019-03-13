class UserAuthentication::Standard < UserAuthentication
  class AuthenticationError < StandardError; end

  def initialize(login = nil, password = nil)
    @login = login
    @password = password
  end

  def perform
    raise AuthenticationError if (login.blank? || password.blank?)
  end

  private

  attr_reader :login, :password
end