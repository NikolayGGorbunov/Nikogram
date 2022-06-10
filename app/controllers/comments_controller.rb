class CommentsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  def show
    @comment = Comment.find(params[:id])
  end

  def index
    @comments = Comment.where(post_id: params[:post_id])
  end

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.create(comment_params)
    redirect_to post_path(@post)
  end

  def edit
      @comment = Comment.find(params[:id])
  end

  def update
      @comment = Comment.find(params[:id])

      if @comment.update(comment_params)
        redirect_to @comment.post
      else
        render :new, status: :unprocessable_entity
      end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to post_path(@post)
  end

  private

  def comment_params
      params.require(:comment).permit(:body).merge(user_id: current_user.id)
  end
end
