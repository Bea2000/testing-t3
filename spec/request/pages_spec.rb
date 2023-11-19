require 'rails_helper'

RSpec.describe 'Page', type: :request do
    before do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'cds@uc.cl', role: 'admin')
        sign_in @user
    end

    # describe 'GET /accesorios' do
    #     it 'renders a successful response' do
    #         get '/accesorios'
    #         expect(response).to be_successful
    #     end
    # end

    # describe 'GET /reserva' do
    #     it 'renders a successful response' do
    #         get '/reserva'
    #         expect(response).to be_successful
    #     end
    # end

    describe 'GET /contacto' do
        it 'renders a successful response' do
            get '/contacto'
            expect(response).to be_successful
        end
    end

    describe 'GET /index' do
        it 'renders a successful response' do
            get '/'
            expect(response).to be_successful
        end
    end
end

