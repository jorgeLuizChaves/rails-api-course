class CommentsController < ApplicationController
  before_action :load_article
  skip_before_action :authorize!, only: [:index]

  # GET /article/{article_id}/comments
  def index
    @comments = @article
      .comments.page(params[:page]).per(params[:per_page])
    render json: serializer(@comments)
  end

  # POST /article/{article_id}/comments
  def create
    @comment = @article.comments
        .build comment_params.merge(user: current_user)
    @comment.save!
    render json: serializer(@comment), status: :created, location: @article
  rescue
      render json: @comment.errors, status: :unprocessable_entity
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
end
