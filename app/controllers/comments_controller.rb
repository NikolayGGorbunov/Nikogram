class CommentsController < ApplicationController
  def index
    @comments = Comment.includes(:user).all
  end

  def show
    @comment = Comment.find(params[:id])
  end

  def new
    @comment = Comment.new
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
  end
  private

  def comment_params
      params.require(:comment).permit(:body).merge(user_id: current_user.id)
  end
end
