require "rails_helper"
require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

RSpec.describe LikesController, type: :controller do
  let!(:user0) {User.create!(email: "test0mail@test.com", password: "123456")}
  let!(:post0) {Post.create!(user_id: user0.id, title: "TestTitle0", body: "TestBody0"*5)}
  before {sign_in user0}

  describe '#create' do
    subject(:create) { post :create, params: params }
    let(:params) { { post_id: post0.id, user_id: user0.id } }

    it 'create like' do
      expect { create }.to change { post0.likes.count }.by(1)
    end

    it "redirect to sign in page when user sign out" do
      sign_out user0
      create
      expect(response).to redirect_to(new_user_session_path)
    end

    it "don't create subscribe when user sign out" do
      sign_out user0
      expect { create }.to change{ post0.likes.count }.by(0)
    end
  end


  describe '#destroy' do
    let!(:like0) {post0.likes.create!(user_id: user0.id)}
    subject(:destroy) { delete :destroy, params: params }
    let(:params) { { post_id: post0.id, id: like0.id } }

    it 'delete like' do
      expect { destroy }.to change { post0.likes.count }.by(-1)
    end

    it "redirect to sign in page when user sign out" do
      sign_out user0
      destroy
      expect(response).to redirect_to(new_user_session_path)
    end

    it "don't create subscribe when user sign out" do
      sign_out user0
      expect { destroy }.to change{ post0.likes.count }.by(0)
    end
  end
end
