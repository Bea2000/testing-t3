require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  before(:each) do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
    sign_in @user
    @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
  end

  it 'should get index' do
    get :index
    expect(response).to have_http_status(:success)
  end

  it 'should get index with user logout' do
    sign_out @user
    get :index
    expect(response).to have_http_status(:success)
  end
end
