require 'rails_helper'

RSpec.describe 'Reviews', type: :request do
    before do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'bea@uc.cl', role: 'admin')
        @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
        sign_in @user
    end

    describe 'GET /new' do
        it 'redirect when creating review' do
            post '/review/insertar', params: { tittle: 'John1', description: 'Nonono123!', calification: 5, product_id: @product.id }
            expect(flash[:notice]).to eq('Review creado Correctamente !')
            expect(response).to redirect_to("/products/leer/#{@product[:id]}")
        end

        it 'redirect when creating review with failed request' do
            post '/review/insertar', params: { calification: 5, product_id: @product.id }
            expect(flash[:error]).to eq('Hubo un error al guardar la reseña; debe completar todos los campos solicitados.')
            expect(response).to redirect_to("/products/leer/#{@product[:id]}")
        end
    end

    describe 'GET /update' do
        before do
            @review = Review.create!(tittle: 'John1', description: 'Nonono123!', calification: 5, product_id: @product.id, user_id: @user.id)
        end

        it 'redirect when updating review' do
            patch "/review/actualizar/#{@review[:id]}", params: { tittle: 'John1', description: 'Nonono123!', calification: 5 }
            expect(response).to redirect_to("/products/leer/#{@product[:id]}")
        end

        it 'redirect when updating review with failed request' do
            patch "/review/actualizar/#{@review[:id]}", params: { tittle: 'John1', description: 'Nonono123!', calification: '' }
            expect(flash[:error]).to eq('Hubo un error al editar la reseña. Complete todos los campos solicitados!')
        end
    end
end
