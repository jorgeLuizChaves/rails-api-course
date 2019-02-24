require 'rails_helper'

RSpec.describe AccessToken, type: :model do

  describe '#validations' do
    it 'should have valid factory' do
      token = build :access_token
      expect(token).to be_valid
    end

    it 'should validate token' do
      token = build :access_token, token: nil
      expect(token).not_to be_valid
      expect(token.errors.messages[:token]).to include("can't be blank")
    end
  end

  describe '#new' do
    it 'should generate uniq token' do
      user = create :user
      expect { user.create_access_token }.to change{ AccessToken.count}.by 1
      expect(user.build_access_token).to be_valid
    end

    it 'should generate token once' do
      user = create :user
      access_token = user.create_access_token
      expect(access_token.token).to eq(access_token.reload.token)
    end
  end
end