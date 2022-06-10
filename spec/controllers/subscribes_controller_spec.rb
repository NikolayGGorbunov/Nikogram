require "rails_helper"
require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

RSpec.describe SubscribesController, type: :controller do
  let!(:user0) {User.create!(email: "test0mail@test.com", password: "123456")}
  let!(:user1) {User.create!(email: "test1mail@test.com", password: "123456")}
  let!(:post0) {Post.create!(user_id: user0.id, title: "TestTitle0", body: "TestBody0"*5)}
  before {sign_in user1}

  describe '#create' do
    subject(:create) { post :create, params: params }
    let(:params) { { post_id: post0.id, user_id: user0.id } }

    it 'create subscribe' do
      expect { create }.to change { user1.active_subscribes.count }.by(1)
    end

    it "don't create self-subscribe" do
      sign_in user0
      expect { create }.to change { user0.active_subscribes.count }.by(0)
    end

    it "redirect to sign in page when user sign out" do
      sign_out user1
      create
      expect(response).to redirect_to(new_user_session_path)
    end

    it "don't create subscribe when user sign out" do
      sign_out user1
      expect { create }.to change(Subscribe, :count).by(0)
    end
  end

  describe '#destroy' do
    let!(:sub0) {user1.active_subscribes.create!(subscribed_id: user0.id)}
    subject(:destroy) { delete :destroy, params: params }
    let(:params) { { post_id: post0.id, user_id: user0.id, id: sub0.id } }

    it 'delete subscribe' do
      expect { destroy }.to change { user1.active_subscribes.count }.by(-1)
    end

    it "redirect to sign in page when user sign out" do
      sign_out user1
      destroy
      expect(response).to redirect_to(new_user_session_path)
    end

    it "don't create subscribe when user sign out" do
      sign_out user1
      expect { destroy }.to change(Subscribe, :count).by(0)
    end
  end
end
