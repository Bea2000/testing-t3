require 'rails_helper'

RSpec.describe User, type: :request do
    before do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'ef@uc.cl', role: 'admin')
        sign_in @user
    end

    describe 'GET /show' do
        it 'renders a successful response' do
            get '/users/show'
            expect(response).to be_successful
        end
    end

    describe 'GET /deseados' do
        it 'renders a successful response' do
            get '/users/deseados'
            expect(response).to be_successful
        end
    end

    describe 'GET /mensajes' do
        it 'renders a successful response' do
            get '/users/mensajes'
            expect(response).to be_successful
        end
    end

    describe 'PATCH /actualizar_imagen' do
        it 'redirects when image is not present' do
            patch '/users/actualizar_imagen', params: { image: nil }
            expect(flash[:error]).to eq('Hubo un error al actualizar la imagen. Verifique que la imagen es de formato jpg, jpeg, png, gif o webp')
            expect(response).to redirect_to('/users/show')
        end

        it 'redirects when image is valid' do
            patch '/users/actualizar_imagen', params: { image: fixture_file_upload("/fff.png", 'image/png') }
            expect(flash[:notice]).to eq('Imagen actualizada correctamente')
            expect(response).to redirect_to('/users/show')
        end
    end

    describe 'DELETE /eliminar_deseado' do
        it 'redirects when success' do
            @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1000, user_id: @user.id, categories: 'Cancha')
            @user.deseados << @product.id
            delete "/users/eliminar_deseado/#{@product[:id]}"
            expect(flash[:notice]).to eq('Producto quitado de la lista de deseados')
            expect(response).to redirect_to('/users/deseados')
        end

        it 'redirects when error' do
            @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1000, user_id: @user.id, categories: 'Cancha')
            @user.deseados << @product.id
            allow_any_instance_of(User).to receive(:save).and_return(false)
            delete "/users/eliminar_deseado/#{@product[:id]}"
            expect(flash[:error]).to eq('Hubo un error al quitar el producto de la lista de deseados')
            expect(response).to redirect_to('/users/deseados')
        end
    end

end