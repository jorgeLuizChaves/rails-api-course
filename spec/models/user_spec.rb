require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#validate' do
    context 'when provider is some social media' do
      it 'should validate attributes' do
        user = build :user
        expect(user).to be_valid
      end

      it 'should login be unique' do
        user = create :user
        other_user = build :user, login: user.login
        expect(user).to be_valid
        expect(other_user).not_to be_valid
      end

      it 'should validate the presence of login and provider' do
        user = build :user, login: nil, provider: nil
        expect(user).not_to be_valid
        expect(user.errors.messages[:login]).to include("can't be blank")
        expect(user.errors.messages[:provider]).to include("can't be blank")
      end
    end

    context 'when provider is standard' do

      it 'should validate the presence of password' do
        user = build :user, provider: 'standard'
        expect(user).not_to be_valid
        expect(user.errors.messages[:password]).to include "can't be blank"
      end

      it 'should validate parameters' do
        user = build :user, provider: 'standard', password: 'secret'
        expect(user).to be_valid
      end
    end

  end
end