class CommentsController < ApplicationController
  class CommentsNotFound < StandardError; end

  rescue_from CommentsController::CommentsNotFound, with: :comments_not_found

  before_action :load_article
  skip_before_action :authorize!, only: [:index]

  # GET /article/{article_id}/comments
  def index
    STATSD.time("comments.index.count") do
      @comments = @article
      .comments.page(params[:page]).per(params[:per_page])
    raise CommentsNotFound if @comments.count == 0
    render json: serializer(@comments)
    end
    end
  end

  # POST /article/{article_id}/comments
  def create
    STATSD.time("comments.create") do
          @comment = @article.comments
        .build comment_params.merge(user: current_user)
    @comment.save!
    STATSD.increment "comments.create.count"
    render json: serializer(@comment), status: :created, location: @article
  rescue
      STATSD.increment "comments.create.error.count"
      render json:  model_unprocessable(@comment.errors.messages), status: :unprocessable_entity
    end
  end

  private

    def serializer(comment)
      CommentSerializer.new(comment).serialized_json
    end

    def load_article
      @article = Article.find(params[:article_id])
    end

    def comment_params
      params.require(:data).require('attributes').permit(:content) ||
          ActionController::Parameters.new
    end

    def comments_not_found
      error = {
          "status" => "404",
          "source" =>  { "pointer" => "/data/attributes/id" },
          "title" =>   "Comments Not Found",
          "detail" => "This article does not have any comment"
      }
      render json: { "errors" => [ error ] },
             status: :not_found
    end
end
