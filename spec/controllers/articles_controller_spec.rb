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

  end
end