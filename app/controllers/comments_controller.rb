class CommentsController < ApplicationController
  class CommentsNotFound < StandardError; end

  rescue_from CommentsController::CommentsNotFound, with: :comments_not_found

  before_action :load_article
  skip_before_action :authorize!, only: [:index]

  # GET /article/{article_id}/comments
  def index
    @comments = @article
      .comments.page(params[:page]).per(params[:per_page])
    raise CommentsNotFound if @comments.count == 0
    render json: serializer(@comments)
  end

  # POST /article/{article_id}/comments
  def create
    @comment = @article.comments
        .build comment_params.merge(user: current_user)
    @comment.save!
    render json: serializer(@comment), status: :created, location: @article
  rescue
      render json:  model_unprocessable(@comment.errors.messages), status: :unprocessable_entity
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
