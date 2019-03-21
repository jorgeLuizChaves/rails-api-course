require 'rails_helper'

RSpec.describe RegistrationsController do

  context '#create' do
    let(:params_valid) do
      {
          data: {
              attributes: {
                  login: 'jsmith',
                  password: 'password'
              }
          }
      }
    end

    let(:params_invalid) do
      {
          data:{
              attributes: {
                  login: nil,
                  password: nil
              }
          }
      }
    end

    let(:expected_json_error) do
      {
           'source' => { 'pointer' => '/data/attributes/login' },
           'detail' => "can't be blank"
      }
      {
           'source' => { 'pointer' => '/data/attributes/password' },
           'detail' => "can't be blank"
      }
    end

    subject {post :create, params: params_valid}

    describe 'when parameters are valid' do
      it 'should return status code created' do
        subject
        expect(response).to have_http_status :created
      end

      it 'should return proper json' do
        subject
        expect(json_data['attributes']).to include({'login' => 'jsmith'})
      end
    end

    describe 'when parameters are invalid' do
      it 'should return status code unprocessable_entity' do
        post :create, params: params_invalid
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'should return proper json' do
        post :create, params: params_invalid
        expect(json_errors).to include(expected_json_error)
      end
    end
  end
end