require "rails_helper"
require 'database_cleaner/active_record'
include Warden::Test::Helpers

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

RSpec.describe CommentsController, type: :controller do
  let!(:user0) {User.create!(email: "test0mail@test.com", password: "123456")}
  let!(:user1) {User.create!(email: "test1mail@test.com", password: "123456")}
  let!(:post0) {Post.create!(user_id: user0.id, title: "TestTitle0", body: "TestBody0"*5)}
  let!(:comment0) {Comment.create!(user_id: user0.id, post_id: post0.id, body: "TestComment")}
  before {sign_in user0}

  describe '#show' do
    subject(:show) {get :show, params: params}
    let(:params) { {id: comment0.id, post_id: post0.id} }

    it 'render comment template' do
      expect(show).to render_template(:show)
    end

    it "assign comment" do
      show
      expect(assigns(:comment)).to eq(Comment.find(comment0.id))
    end
  end

  describe "#create" do
    subject(:create) { process :create, method: :post, params: params }
    let(:params) { { comment: { post_id: post0.id, body: "NewCommentBody" }, post_id: post0.id } }

    it "create new comment" do
      expect { create }.to change{ post0.comments.count }.by(1)
    end

    it "create comment with right params" do
      create
      expect(Comment.last.body).to eq("NewCommentBody")
      expect(Comment.last.post_id).to eq(post0.id)
    end

    it "redirect to sign in page when user sign out" do
      sign_out user0
      create
      expect(response).to redirect_to(new_user_session_path)
    end
  end





end
