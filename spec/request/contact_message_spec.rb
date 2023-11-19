require 'rails_helper'

RSpec.describe 'ContactMessages', type: :request do
    before do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'bea@uc.cl', role: 'admin')
        @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
        sign_in @user
    end

    describe 'GET /new' do
        it 'redirect when creating contact message' do
            post '/contacto/crear', params: { contact: {name: 'John1', mail: 'john@gmail.com', title: 'Nonono123!', body: 'Nonono123!', phone: '+56977743528' }}
            expect(flash[:notice]).to eq('Mensaje de contacto enviado correctamente')
            expect(response).to redirect_to('/contacto')
        end

        it 'redirect when creating contact message with failed request' do
            post '/contacto/crear', params: { contact: {name: 'John1', mail: 'fsfs', title: 'Nonono123!', body: 'Nonono123!', phone: '+56977743528'}}
            expect(flash[:alert]).to eq('Error al enviar el mensaje de contacto: Mail: no es válido')
            expect(response).to redirect_to('/contacto')
        end
    end

    describe 'GET /mostrar' do
        it 'returns http success' do
            get '/contacto'
            expect(response).to have_http_status(:success)
        end

        it 'shows messages in correct descending order' do
            @contact_message = ContactMessage.create!(title: 'titulo', body: 'descripcion', name: 'nombre', mail: 'ddsd@uc.cl')
            @contact_message2 = ContactMessage.create!(title: 'titulo2', body: 'descripcion2', name: 'nombre2', mail: 'dnkja@uc.cl')
            @contact_message3 = ContactMessage.create!(title: 'titulo3', body: 'descripcion3', name: 'nombre3', mail: 'fsdffw@uc.cl')
            @contact_message.created_at = 3.days.ago
            @contact_message2.created_at = 2.days.ago
            @contact_message3.created_at = 1.days.ago

            get '/contacto'

            contact_messages = assigns(:contact_messages)

            expect(contact_messages[0]).to eq(@contact_message3)
            expect(contact_messages[1]).to eq(@contact_message2)
            expect(contact_messages[2]).to eq(@contact_message)
        end
    end

    describe 'GET /eliminar' do
        before do
            @contact_message = ContactMessage.create!(title: 'titulo', body: 'descripcion', name: 'nombre', mail: 'sdfe@uc.cl')
        end
        it 'redirect when deleting contact message' do
            delete "/contacto/eliminar/#{@contact_message.id}"
            expect(flash[:notice]).to eq('Mensaje de contacto eliminado correctamente')
            expect(response).to redirect_to('/contacto')
        end

        it 'redirect when deleting contact message without being admin' do
            @user.role = 'normal'
            delete "/contacto/eliminar/#{@contact_message.id}"
            expect(flash[:alert]).to eq('Debes ser un administrador para eliminar un mensaje de contacto.')
            expect(response).to redirect_to('/contacto')
        end

        it 'redirect when deleting contact message with failed request' do
            delete "/contacto/eliminar/0"
            expect(flash[:alert]).to eq('Error al eliminar el mensaje de contacto')
            expect(response).to redirect_to('/contacto')
        end
    end

    describe 'GET /limpiar' do
        before do
            @contact_message = ContactMessage.create!(title: 'titulo', body: 'descripcion', name: 'nombre', mail: 'dsf@uc.cl')
            @contact_message2 = ContactMessage.create!(title: 'titulo2', body: 'descripcion2', name: 'nombre2', mail: 'dd@uc.cl')
        end

        it 'redirect when deleting all contact messages' do
            delete '/contacto/limpiar'
            expect(flash[:notice]).to eq("Mensajes de contacto eliminados correctamente")
            expect(response).to redirect_to('/contacto')
        end

        it 'redirect when deleting all contact messages without being admin' do
            @user.role = 'normal'
            delete '/contacto/limpiar'
            expect(flash[:alert]).to eq('Debes ser un administrador para eliminar los mensajes de contacto.')
            expect(response).to redirect_to('/contacto')
        end

        it 'redirect when deleting all contact messages with failed request' do
            @contact_message.destroy
            @contact_message2.destroy
            delete '/contacto/limpiar'
            expect(flash[:alert]).to eq('Error al eliminar los mensajes de contacto')
            expect(response).to redirect_to('/contacto')
        end
    end

end