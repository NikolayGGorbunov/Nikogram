class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]

  def index
    @posts = Post.includes(:comments).all
  end

  def feed
    @posts = Post.includes(:comments).where(user_id: current_user.subscribing.all.ids)
  end

  def show
    @post = Post.includes(:comments).find(params[:id])
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
        if params[:post][:images].present?
          params[:post][:images].each do |image|
            @post.images.attach(image)
          end
        end
        redirect_to @post
      else
        render :new, status: :unprocessable_entity
      end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy

    redirect_to posts_path
  end

  private

  def post_params
      params.require(:post).permit(:title, :body)
  end
end
