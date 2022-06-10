require "rails_helper"
require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

RSpec.describe PostsController, type: :controller do
    let!(:user0) {User.create!(email: "test0mail@test.com", password: "123456")}
    let!(:user1) {User.create!(email: "test1mail@test.com", password: "123456")}
    let!(:comments) {Comment.create(body: "testcomment")}
    let!(:post0) {Post.create!(user_id: user0.id, title: "TestTitle0", body: "TestBody0"*5)}
    let!(:post1) {Post.create!(user_id: user1.id, title: "TestTitle1", body: "TestBody1"*5)}
    let!(:subscribsion) {Subscribe.create!(subscriber_id: user0.id, subscribed_id: user1.id)}
    before {sign_in user0}


  describe "#index" do
    it "assign all posts" do
      get :index
      expect(assigns(:posts)).to eq(Post.includes(:comments).all)
    end

    it "render index template" do
      get :index
      expect(assigns(:posts)).to render_template("index")
    end
  end

  describe "#feed" do
    it "return subscribed user's posts" do
      get :feed
      expect(assigns(:posts)).to eq(Post.includes(:comments).where(user_id: user0.subscribing.all.ids))
    end

    it "return empty (subscribes doesn't exist)" do
      sign_in user1
      get :feed
      expect(assigns(:posts)).to eq([])
    end

    it "redirect to sign in page when user sign out" do
      sign_out user0
      get :feed
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "#show" do

    subject(:show) { get :show, params: post_id}
    let(:post_id) { { id: post0.id } }
    it "return single post" do
      expect(show).to render_template(:show)
    end

    it "return right post" do
      show
      expect(assigns(:post)).to eq(post0)
    end

    subject(:not_show) { get :show, params: not_post_id}
    let(:not_post_id) { { id: post0.id - 1 } }
    it "exception post not found" do
      expect { not_show }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe "#create" do
    subject(:create_post) { process :create, method: :post, params: params }
    let(:params) { { post: { title: "TestTitle2", body: "TestBody2"*5 } } }

    it "increase post count" do
      expect { create_post }.to change(Post, :count).by(1)
    end

    it "create post with right params" do
      create_post
      expect(Post.last.title).to eq("TestTitle2")
      expect(Post.last.body).to eq("TestBody2"*5)
    end

    it "redirect to sign in page when user sign out" do
      sign_out user0
      create_post
      expect(response).to redirect_to(new_user_session_path)
    end

    subject(:create_wrong_post) { process :create, method: :post, params: wrong_params }
    let(:wrong_params) { { post: { title: 0, body: 0 } } }

    it "don't create post" do
      expect { create_wrong_post }.to change(Post, :count).by(0)
    end
  end

  describe "#update" do
    subject(:update_post) { patch :update, params: params }
    let(:params) { { post: { title: 'NewTestTitle0'}, id: post0.id } }
    it "update post" do
      expect { update_post }.to change { Post.find(post0.id).title.length }.by_at_least(3)
    end

    it "redirect to sign in page when user sign out" do
      sign_out user0
      update_post
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe '#destroy' do
    subject(:destroy_post) { delete :destroy, params: params }
    let(:params) { { id: post0.id } }
    it "destroy post" do
      expect { destroy_post }.to change(Post, :count).by(-1)
    end

    it "exeption post not found (when it's not your post)" do
      sign_in user1
      expect {destroy_post}.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "redirect to sign in page when user sign out" do
      sign_out user0
      destroy_post
      expect(response).to redirect_to(new_user_session_path)
    end
  end

end
