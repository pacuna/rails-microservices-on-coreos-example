class CommentsController < ApplicationController
  respond_to :json
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  def index
    @comments = Comment.all
    respond_with @comments
  end

  def show
    @comment = Comment.find(params[:id])
    respond_with @comment
  end

  def create
    @comment = Comment.new(author_id: params[:author_id], body: params[:body])
    if @comment.save
      respond_with @comment
    end
  end

  def by_author
    @comments = Comment.where(author_id: params[:author_id])
    respond_with @comments
  end
end
