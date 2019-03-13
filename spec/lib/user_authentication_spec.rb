require 'rails_helper'

describe UserAuthentication do

  context 'when initialized w/ code' do
    describe '#initialize' do
      subject { described_class.new(code: 'sample') }
      let(:authentication_instance) { UserAuthentication::Oauth }

      it 'should initialize proper authenticator' do
        expect(authentication_instance).to receive(:new).with('sample')
        subject
      end
    end
  end

  context 'when initialized w/ username and password' do
    describe '#initialize' do
      subject { described_class.new(login: 'login', password: 'password') }
      let(:authentication_instance) { UserAuthentication::Standard }

      it 'should initialize proper authenticator' do
        expect(authentication_instance).to receive(:new).with('login', 'password')
        subject
      end
    end
  end
end