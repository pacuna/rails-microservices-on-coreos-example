require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index, {format: :json}
      expect(response).to have_http_status(:success)
    end

    it 'returns all the users in JSON format' do
      # user1 = User.create name: 'User 1', email: 'user1@mail.com'
      # user2 = User.create name: 'User 2', email: 'user2@mail.com'
      # get :index, {format: :json}
      # expect(JSON.parse(response.body)).to ([user1.as_json, user2.as_json])
    end
  end

  # describe "GET #show" do
  #   it "returns http success" do
  #     get :show
  #     expect(response).to have_http_status(:success)
  #   end
  # end

end
