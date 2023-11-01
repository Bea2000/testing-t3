require 'rails_helper'

RSpec.describe Message, type: :model do
    before(:each) do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'mail@gmail.com')
        @owner = User.create!(name: 'John2', password: 'Nonono123!', email: 'mail2@gmail.com')
        @product = Product.create!(nombre: 'tenis', precio: 4000, stock: 1, user_id: @owner.id, categories: 'Cancha')
        @message = Message.create!(body: 'body', user_id: @user.id, product_id: @product.id)
    end

    it 'is valid with valid attributes' do
        expect(@message).to be_valid
    end
end