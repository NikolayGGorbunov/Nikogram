class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]

  def index
    @posts = Post.includes(:comments).all.with_attached_images
  end

  def show
    @post = Post.includes(:comments, :user).find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.new(post_params)

    if @post.save
      redirect_to @post
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
      @post = Post.find(params[:id])
  end

  def update
      @post = Post.find(params[:id])

      if @post.update(post_params)
        redirect_to @post
      else
        render :new, status: :unprocessable_entity
      end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    redirect_to posts_path
  end
  private

  def post_params
      params.require(:post).permit(:title, :body, images: [])
  end
end
