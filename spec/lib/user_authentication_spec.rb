require 'rails_helper'

describe UserAuthentication do

  shared_examples_for 'authenticator' do
    it 'should create and set user access token' do
      expect(authentication.authentication).to receive(:perform).and_return(true)
      expect(authentication.authentication).to receive(:user).at_least(:once).and_return(user)
      expect { subject }.to change{AccessToken.count}.by 1
    end
  end

  context 'when initialized w/ code' do
    describe '#initialize' do
      context 'when is Oauth auth' do
        subject { described_class.new(code: 'sample') }
        let(:authentication_instance) { UserAuthentication::Oauth }

        it 'should initialize proper authenticator' do
          expect(authentication_instance).to receive(:new).with('sample')
          subject
        end
      end

      context 'when is Standard auth' do
        subject { described_class.new(login: 'sample', password: 'password') }
        let(:authentication_instance) { UserAuthentication::Standard }

        it 'should initialize proper authenticator' do
          expect(authentication_instance).to receive(:new).with('sample', 'password')
          subject
        end
      end
    end

    describe '#perform' do
      let(:authentication) { described_class.new(code: 'sample')}
      let(:authentication_instance) { UserAuthentication::Oauth }

      subject { authentication.perform }
      let(:user) {create :user, login: 'jsmith', password: 'password'}
      it_behaves_like 'authenticator'
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

    describe '#perform' do
      let(:authentication) { described_class.new(login: 'jsmith', password: 'password')}
      let(:authentication_instance) { UserAuthentication::Standard }

      subject { authentication.perform }
      let(:user) {create :user, login: 'jsmith', password: 'password'}
      # it 'should instantitiate a Standard ' do
      #   expect(authentication_instance).to receive(:new).with('jsmith', 'password')
      # end

      it_behaves_like 'authenticator'
    end
  end




end