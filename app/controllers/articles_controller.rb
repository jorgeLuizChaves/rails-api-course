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
    article = current_user.articles.build(article_params)
    if article.valid?
      article.save!
      render json: serializer(article), status: :created
    else
      errors = article_unprocessable(article.errors.messages)
      render json: { "errors" => errors },
             status: :unprocessable_entity
    end
  end

  def update
    article = Article.find(params[:id])
    article.update_attributes!(article_params)
    render json: serializer(article), status: :ok
    rescue ActiveRecord::RecordNotFound
      handle_authorization_error
  end

  def destroy
    article = current_user.articles.find(params[:id])
    article.destroy
    head :no_content
    rescue ActiveRecord::RecordNotFound
      handle_authorization_error
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

  def article_unprocessable(messages)
    errors = []
    messages.each_pair do |k, v|
      errors << {
          "source" => { "pointer" => "/data/attributes/#{k}" },
          "detail" => v[0]
      }
    end
    errors
  end

  def article_params
    params.require(:data).require(:attributes)
        .permit(:title, :content, :slug) ||
    ActionController::Parameters.new
  end
end