require 'rails_helper'

RSpec.describe Review, type: :model do
    before(:each) do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'mail@gmail.com')
        @owner = User.create!(name: 'John2', password: 'Nonono123!', email: 'mail2@gmail.com')
        @product = Product.create!(nombre: 'tenis', precio: 4000, stock: 1, user_id: @owner.id, categories: 'Cancha')
        @review = Review.create!(tittle: 'titulo', description: 'descripcion', calification: 3, product_id: @product.id, user_id: @user.id)
    end

    it 'is valid with valid attributes' do
        expect(@review).to be_valid
    end
end