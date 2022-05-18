class SubscribesController < ApplicationController
  before_action :authenticate_user!

  def create
    binding.pry
    current_user.active_subscribes.create(subscribed_id: params[:format])
  end

  def destroy
    binding.pry
    current_user.active_subscribes.find_by(subscribed_id: params[:id]).destroy
  end

  def already_subscribed?(other_user_id)
    current_user.subscribing.include?(other_user_id)
  end

end
