class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :active_subscribes, class_name: "Subscribe", foreign_key: "subscriber_id", dependent: :destroy
  has_many :subscribing, through: :active_subscribes, source: :subscribed
  has_many :subscribers, through: :passive_subscribes

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
