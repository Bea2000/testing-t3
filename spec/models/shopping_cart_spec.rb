require 'rails_helper'

RSpec.describe ShoppingCart, type: :model do
    before (:each) do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'mail@gmail.com')
        @owner = User.create!(name: 'John2', password: 'Nonono123!', email: 'mail2@gmail.com')
        @product = Product.create!(nombre: 'tenis', precio: 4000, stock: 1, user_id: @owner.id, categories: 'Cancha')
        @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {})
    end

    it 'is valid with valid attributes' do
        expect(@shopping_cart).to be_valid
    end

    it 'should return 0 when the shopping cart is empty' do
        expect(@shopping_cart.precio_total).to eq(0)
    end

    it 'should return the total price of the products in the shopping cart' do
        @shopping_cart.products = {@product.id => 1}
        expect(@shopping_cart.precio_total).to eq(4000)
    end

    it 'should return the shipping cost of the products in the shopping cart' do
        @shopping_cart.products = {@product.id => 1}
        expect(@shopping_cart.costo_envio).to eq(1200)
    end
end