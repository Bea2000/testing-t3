require 'rails_helper'

RSpec.describe Message, type: :request do
    before do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'sde@uc.cl', role: 'admin')
        @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
        @message = Message.create!(body: 'descripcion', product_id: @product.id, user_id: @user.id)
        sign_in @user
    end

    describe 'GET /insertar' do
        it 'redirect when creating message' do
            sign_in @user
            post '/message/insertar', params: { message: { body: 'descripcion' }, product_id: @product.id }
            expect(flash[:notice]).to eq('Pregunta creada correctamente!')
            expect(response).to redirect_to("/products/leer/#{@product.id}")
        end

        it 'redirect when creating message with failed request' do
            sign_in @user
            post '/message/insertar', params: { message: { body: '' }, product_id: @product.id }
            expect(flash[:error]).to eq('Hubo un error al guardar la pregunta. ¡Completa todos los campos solicitados!')
            expect(response).to redirect_to("/products/leer/#{@product.id}")
        end
    end

    describe 'GET /eliminar' do
        it 'redirect when deleting message' do
            delete '/message/eliminar', params: { message_id: @message.id, product_id: @product.id }
            expect(response).to redirect_to("/products/leer/#{@product.id}")
            expect(Message.exists?(@message.id)).to be_falsey
        end
    end
end