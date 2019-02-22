require 'rails_helper'

describe ArticlesController do
  describe '#index' do
    subject { get :index }
    it 'should return success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      number_of_articles = 2
      create_list :article, number_of_articles
      subject
      Article.recent.each_with_index do |article, index|
        expect(json_data[index]['attributes']).to eq({
          'title' => article.title,
          'content' => article.content,
          'slug' => article.slug
        })
      end
    end

    it 'should return articles in the proper order' do
      oldest = create :article
      newest = create :article
      subject
      expect(json_data.first['id']).to eq(newest.id.to_s)
      expect(json_data.last['id']).to eq(oldest.id.to_s)
    end

    it 'should return paginated articles' do
      articles = create_list :article, 9
      get :index, params: {page: 1, per_page: 1}
      expect(json_data.length).to eq 1
      expect(json_data.first['id']).to eq articles.last.id.to_s
    end
  end

  describe '#show' do
    let(:article) {
      create :article
    }

    subject { get :show, params: {id: article.id}  }

    it 'should return status code 200' do
      subject
      expect(response).to have_http_status :ok
    end
    it 'should retrieve an article by id' do
      subject
      expect(json_data['attributes']).to eq({
          "title" => article.title,
          "content" => article.content,
          "slug" => article.slug
      })
    end

    it 'should return :not_found to unregistred articles' do
      get :show, params: {id: 99001}
      expect(response).to have_http_status :not_found
    end

    it 'should return proper json when article is not found' do
      get :show, params: {id: 99001}
      error = {
          "status" => "404",
          "source" =>  { "pointer" => "/data/attributes/id" },
          "title" =>   "Article Not Found",
          "detail" => "This article does not exist in our registry"
      }
      expect(json_errors).to include(error)
    end
  end

  describe "#create" do
    subject { post :create }

    context 'when no code provided' do
      it_behaves_like 'forbidden_access'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_access'
    end

    context 'when authorized' do
      let(:access_token) { create :access_token }
      before { request.headers['authorization'] =  "Bearer #{access_token.token}"}

      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
              data: {
                  attributes: {
                      title: nil,
                      content: nil
                  }
              }
          }
        end
        subject {post :create, params: invalid_attributes}

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'should return proper json' do
          subject
          expect(json_errors).to include(
            {
              "source" => { "pointer" => "/data/attributes/title" },
              "detail" =>  "can't be blank"},
            {
              "source" => { "pointer" => "/data/attributes/content" },
              "detail" =>  "can't be blank"
            },
            {
              "source" => { "pointer" => "/data/attributes/slug" },
              "detail" =>  "can't be blank"
            })
        end
      end

      context 'when valid parameters provide' do
        let(:user) do
          create :user
        end

        let(:valid_attributes) do
          {
              data: {
                  attributes: {
                      title: "awesome article",
                      content: "awesome content",
                      slug: "awesome-article",
                      user: user
                  }
              }
          }
        end
        subject {post :create, params: valid_attributes}

        it 'should return 201 status code' do
          subject
          expect(response).to have_http_status :created
        end

        it 'should create an article' do
          expect { subject }.to change { Article.count }.by 1
        end
      end
    end
  end

  describe "#update" do
    let(:article) do
      create :article
    end

    let(:access_token_valid) do
      create :access_token
    end
    let(:token) do
      token = access_token_valid.token
    end

    let(:update_article) do
      {
          "data" => {
              "attributes" => {
                  "title" => "updated-title",
                  "content" => "updated-content",
                  "slug" => "updated-slug"
              }
          }
      }
    end

    subject {patch :update, params: update_article.clone.merge(id: article.id)}

    context 'when no code is provided' do
      it_behaves_like 'forbidden_access'
    end

    context 'when invalid code is provided' do
      before { request.headers['authorization'] = 'Invalid token'}
      it_behaves_like 'forbidden_access'
    end

    context 'when valid code is provided' do
      before { request.headers['authorization'] = "Bearer #{token}" }

      it 'should return status code 200' do
        subject
        expect(response).to have_http_status :ok
      end

      it 'should return proper json' do
        subject
        # p response.body
        expect(json_data).to include(update_article['data'])
      end
    end

    context 'when user try to edit articles that not belong to him' do
      let(:other_user) { create :user }
      subject {delete :destroy, params: {id: other_user.id }}
      it_behaves_like 'forbidden_access'
    end
  end

  describe "#destroy" do
    let(:user) { create :user }
    let(:article) { create :article, user: user }

    let(:token) { user.create_access_token.token }

    subject {delete :destroy, params: {id: article.id}}

    context 'when no code is provided' do
      it_behaves_like 'forbidden_access'
    end

    context 'when invalid code is provided' do
      before { request.headers['authorization'] = 'Invalid token'}
      it_behaves_like 'forbidden_access'
    end

    context 'when valid code is provided' do
      before { request.headers['authorization'] = "Bearer #{token}"}

      it 'should return status code ok' do
        subject
        expect(response).to have_http_status :no_content
      end

      it 'should remove an article' do
        article
        expect { subject }.to change{ Article.count }.by -1
      end
    end

    context 'when trying to remove not owned article' do
      before {request.headers["Authorization"] = "Bearer #{token}"}
      let(:other_user) { create :user }
      subject {delete :destroy, params: {id: other_user.id }}
      it_behaves_like 'forbidden_access'
    end
  end
end