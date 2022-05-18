require "rails_helper"

RSpec.describe PostsController, type: :controller do
    let!(:user0) {User.create!(email: "test0mail@test.com", password: "123456")}
    let!(:user1) {User.create!(email: "test1mail@test.com", password: "123456")}
    let!(:comments) {Comment.create(body: "testcomment")}
    let!(:posts) do
      Post.create!(user_id: user0.id, title: "TestTitle0", body: "TestBody0"*5)
      Post.create!(user_id: user1.id, title: "TestTitle1", body: "TestBody1"*5)
    end
    let!(:subscribsion) {Subscribe.create!(subscriber_id: user0.id, subscribed_id: user1.id)}
    before {sign_in user0}


  describe "#index" do
    it "return all posts" do
      get :index
      expect(assigns(:posts)).to eq(Post.includes(:comments).all.with_attached_images)
    end
  end

  describe "#feed" do
    it "return subscribed user's posts" do
      get :feed
      expect(assigns(:posts)).to eq(Post.includes(:comments).where(user_id: user0.subscribing.all.ids))
    end

    it "return nothing (subscribes doesn't exist)" do
      sign_in user1
      get :feed
      expect(assigns(:posts)).to eq(Post.includes(:comments).where(user_id: user1.subscribing.all.ids))
    end

    it "return nothing (subscribes doesn't exist)" do
      sign_out user0
      get :feed
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "#show" do
    subject(:show) { get :show, params: post_id}
    let(:post_id) { { id: 1 } }
    it "return single post" do
      expect(show).to render_template(:show)
    end

    subject(:not_show) { get :show, params: not_post_id}
    let(:not_post_id) { { id: 0 } }
    it "return exception" do
      expect { not_show }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe "#new" do
    it "create empty post" do
      get :new
      expect(assigns(:post)).to be_a_new(Post)
    end
  end

  describe "#create" do
    subject(:create_post) { process :create, method: :post, params: params}
    let(:params) { { post: { title: "TestTitle2", body: "TestBody2"*5 } } }
    it "create new post" do
      expect { create_post }.to change(Post, :count).by(1)
    end
  end

end
