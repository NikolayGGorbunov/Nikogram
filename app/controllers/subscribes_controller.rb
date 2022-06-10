class SubscribesController < ApplicationController
  before_action :authenticate_user!
  before_action :connect_post, only: [:create, :destroy]
  before_action :connect_subscribes, only: [:create, :destroy]

  def create
    if !self_subscribe?
      @subscribes.create(subscribed_id: params[:user_id])
    end
    redirect_to post_path(@post)
  end

  def destroy
    @subscribes.find_by(subscribed_id: params[:user_id]).destroy
    redirect_to post_path(@post)
  end

  private

  def connect_post
    @post = Post.find(params[:post_id])
  end

  def connect_subscribes
    @subscribes = current_user.active_subscribes
  end

  def already_subscribed?
    Subscribe.where(subscriber_id: current_user.id, subscribed_id: params[:user_id]).exist?
  end

  def self_subscribe?
    current_user.id == params[:user_id].to_i
  end

end
