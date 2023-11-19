require 'rails_helper'

RSpec.describe Solicitud, type: :request do
    before do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'sbd@uc.cl', role: 'admin')
        @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1000, user_id: @user.id, categories: 'Cancha')
        sign_in @user
    end

    describe 'GET /index' do
        it 'renders a successful response' do
            get '/solicitud/index'
            expect(response).to be_successful
        end
    end

    describe 'POST /insertar' do
        it 'redirects when not enough stock' do
            post '/solicitud/insertar', params: { product_id: @product.id, solicitud: { stock: 2000 }}
            expect(flash[:error]).to eq('No hay suficiente stock para realizar la solicitud!')
            expect(response).to redirect_to("/products/leer/#{@product.id}")
        end

        it 'redirects when success' do
            post '/solicitud/insertar', params: { product_id: @product.id, solicitud: { stock: 200 }}
            expect(flash[:notice]).to eq('Solicitud de compra creada correctamente!')
            expect(response).to redirect_to("/products/leer/#{@product.id}")
        end

        it 'redirects when solicitud is not saved' do
            allow_any_instance_of(Solicitud).to receive(:save).and_return(false)
            post '/solicitud/insertar', params: { product_id: @product.id, solicitud: { stock: 200 }}
            expect(flash[:error]).to eq('Hubo un error al guardar la solicitud!')
            expect(response).to redirect_to("/products/leer/#{@product.id}")
        end

        it 'changes reservation_info when reservation_datetime is present' do
            post '/solicitud/insertar', params: { product_id: @product.id, solicitud: { stock: 200, reservation_datetime: '2021-06-01 12:00' }}
            @solicitud = Solicitud.last
            expect(@solicitud.reservation_info).to eq('Solicitud de reserva para el día 01/06/2021, a las 12:00 hrs')
        end
    end

    describe 'DELETE /eliminar' do
        it 'redirects when success' do
            @solicitud = Solicitud.create!(status: 'Pendiente', stock: 200, product_id: @product.id, user_id: @user.id)
            delete "/solicitud/eliminar/#{@solicitud[:id]}"
            expect(flash[:notice]).to eq('Solicitud eliminada correctamente!')
            expect(response).to redirect_to('/solicitud/index')
        end

        it 'redirects when solicitud is not destroyed' do
            allow_any_instance_of(Solicitud).to receive(:destroy).and_return(false)
            @solicitud = Solicitud.create!(status: 'Pendiente', stock: 200, product_id: @product.id, user_id: @user.id)
            delete "/solicitud/eliminar/#{@solicitud[:id]}"
            expect(flash[:error]).to eq('Hubo un error al eliminar la solicitud!')
            expect(response).to redirect_to('/solicitud/index')
        end
    end

    describe 'PATCH /actualizar' do
        it 'redirects when success' do
            @solicitud = Solicitud.create!(status: 'Pendiente', stock: 200, product_id: @product.id, user_id: @user.id)
            patch "/solicitud/actualizar/#{@solicitud[:id]}"
            expect(flash[:notice]).to eq('Solicitud aprobada correctamente!')
            expect(response).to redirect_to('/solicitud/index')
        end

        it 'redirects when solicitud is not updated' do
            allow_any_instance_of(Solicitud).to receive(:update).and_return(false)
            @solicitud = Solicitud.create!(status: 'Pendiente', stock: 200, product_id: @product.id, user_id: @user.id)
            patch "/solicitud/actualizar/#{@solicitud[:id]}"
            expect(flash[:error]).to eq('Hubo un error al aprobar la solicitud!')
            expect(response).to redirect_to('/solicitud/index')
        end
    end
end