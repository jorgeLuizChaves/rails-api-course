class ArticlesController < ApplicationController
  def index
    articles = Article.recent
        .page(params[:page])
        .per(params[:per_page])

    render json: serializer.new(articles).serialized_json
  end

  def show

  end

  private
  def serializer
    ArticleSerializer
  end
end