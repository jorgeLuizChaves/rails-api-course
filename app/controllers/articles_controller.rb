class ArticlesController < ApplicationController

  class ArticleNotFoundError < StandardError; end

  rescue_from  ArticlesController::ArticleNotFoundError, with: :article_not_found

  skip_before_action :authorize!, only: [:index, :show]
  def index
    articles = Article.recent
        .page(params[:page])
        .per(params[:per_page])
    render json: serializer(articles)
  end

  def show
    article = Article.find_by(id: params[:id])
    raise ArticleNotFoundError unless article
    render json: serializer(article), status: :ok
  end

  def create

  end

  private
  def serializer(obj)
    ArticleSerializer.new(obj).serialized_json
  end

  def article_not_found
    error = {
        "status" =>  "404",
        "source" => { "pointer": "/data/attributes/id" },
        "title" =>   "Article Not Found",
        "detail" => "This article does not exist in our registry"
    }
    render json: {"errors" => [ error ]}, status: :not_found
  end
end