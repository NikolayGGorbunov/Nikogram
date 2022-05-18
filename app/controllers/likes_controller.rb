class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :connect_post
  before_action :connect_like, only: :destroy

  def create
    @post.likes.create(user_id: current_user.id)
    redirect_to post_path(@post)
  end

  def destroy
    if already_liked?
      @like.destroy
    end
    redirect_to post_path(@post)
  end

  private

  def connect_post
    @post = Post.find(params[:post_id])
  end

  def connect_like
    @like = @post.likes.find(params[:id])
  end

  def already_liked?
    Like.where(user_id: current_user.id, post_id: params[:post_id]).exists?
  end
end
