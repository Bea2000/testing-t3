require 'rails_helper'

RSpec.describe Solicitud, type: :model do
    before (:each) do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'bea@gmail.com')
        @owner = User.create!(name: 'John2', password: 'Nonono123!', email: 'bea2@gmail.com')
        @product = Product.create!(nombre: 'tenis', precio: 4000, stock: 1, user_id: @owner.id, categories: 'Cancha')
        @solicitud = Solicitud.create!(status: 'pendiente', stock: 1, product_id: @product.id, user_id: @user.id)
    end

    it 'is valid with valid attributes' do
        expect(@solicitud).to be_valid
    end
end
