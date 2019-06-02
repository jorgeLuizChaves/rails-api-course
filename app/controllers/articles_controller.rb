class ArticlesController < ApplicationController

  class ArticleNotFoundError < StandardError; end

  rescue_from  ArticlesController::ArticleNotFoundError, with: :article_not_found

  skip_before_action :authorize!, only: [:index, :show]

  def index
    STATSD.increment "articles.index.count"
    STATSD.time("articles.#{__method__.to_s}.count") do
      articles = Article.recent
        .page(params[:page])
        .per(params[:per_page])
      render json: serializer(articles)
    end
  end

  def show
    STATSD.time("articles.show.count") do
      STATSD.increment "articles.show.count"
      article = Article.find_by(id: params[:id])
      raise ArticleNotFoundError unless article
      render json: serializer(article), status: :ok
    end
  end

  def create
    STATSD.time("articles.create.count") do
      article = current_user.articles.build(article_params)
      if article.valid?
        article.save!
        STATSD.increment "articles.create.count"
        render json: serializer(article), status: :created
      else
        STATSD.increment "articles.create.error.count"
        errors = model_unprocessable(article.errors.messages)
        render json: errors , status: :unprocessable_entity
      end
    end
  end

  def update
    STATSD.time("articles.update") do
      article = Article.find(params[:id])
    article.update_attributes!(article_params)
    STATSD.increment "articles.update.count"
    render json: serializer(article), status: :ok
    rescue ActiveRecord::RecordNotFound
      STATSD.increment "articles.update.error.count"
      handle_authorization_error
    end
  end

  def destroy
    STATSD.time("articles.destroy") do
      article = current_user.articles.find(params[:id])
    article.destroy
    head :no_content
    rescue ActiveRecord::RecordNotFound
      STATSD.increment "articles.destroy.error.count"
      handle_authorization_error
    end
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

  def article_params
    params.require(:data).require(:attributes)
        .permit(:title, :content, :slug) ||
    ActionController::Parameters.new
  end
end