class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
  belongs_to :user

  validates :title, presence: true, length: { minimum: 2, maximum: 100 }
  validates :body, presence: true, length: { minimum: 10, maximum: 500 }
end
