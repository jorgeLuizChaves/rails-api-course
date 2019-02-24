require 'rails_helper'

RSpec.describe CommentsController, type: :controller do

  let(:user) { create :user }
  let(:access_token) { create :access_token }
  let(:article) { create :article }
  let(:comment) { create :comment, user: user, article: article }

  describe "#create" do

    subject {post :create, params: valid_attributes.merge(article_id: article.id ) }

    let(:valid_attributes) do
      {
          data: {
              attributes: {
                  content: "content",
              }
          }
      }
    end

    let(:invalid_parameters) do
      {
          data: {
              attributes: {
                  content: "",
              }
          }
      }
    end

    context 'when is not authorized' do
      context 'when no code provided' do
        it_behaves_like 'forbidden_access'
      end
    end

    context 'when is authorized' do
      before { request.headers['Authorization'] = "Bearer #{access_token.token}"}
      context 'when parameters are valid' do
        it 'should return status code 201' do
          subject
          expect(response).to have_http_status :created
        end

        it 'should return proper json' do
          subject
          expect(json_data['attributes']).to include({ "content" => "content" })
        end
      end

      context "when parameters aren't valid" do
        subject {post :create, params: invalid_parameters.merge(article_id: article.id)}
        it 'should return status code 422' do
          subject
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'should return json error' do
          subject
          expect(json_errors).to include({"source" => {"pointer" => "/data/attributes/content"},"detail" => "can't be blank"})
        end
      end
    end
  end

  describe "#show" do
    let(:user) { create :user}
    let(:article) { create :article, user: user }

    subject { get :index, params: {article_id: article.id, page: 1, per_page: 10} }

    it "should return proper status code 200" do
      create :comment, article: article
      subject
      expect(response).to have_http_status :ok
    end

    it 'should result be paginated' do
      expected_quantity = 3
      number_of_comments = 8
      create_list :comment, number_of_comments, article: article, user: user
      get(:index, params: {article_id: article.id, page: 1, per_page: 3})
      expect(json_data.count).to eq(expected_quantity)
    end

    it 'should return proper json' do
      number_of_comments = 8
      comments = create_list :comment, number_of_comments, article: article, user: user
      subject
      comments.each_with_index do |comment, index|
      expect(json_data[index]['attributes']).to include(
       { "content" => comment.content })

      expect(json_data.count).to eq(comments.count)
      end
    end

    context 'when there is no comments' do
      it 'should return status code not found' do
        subject
        expect(response).to have_http_status :not_found
      end
    end
  end
end