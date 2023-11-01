require 'rails_helper'

RSpec.describe ContactMessage, type: :model do
    before(:each) do
        @contact_message = ContactMessage.create!(title: 'titulo', body: 'descripcion', name: 'nombre', mail: 'mail@gmail.com', phone: '+56912345678')
    end

    it 'is valid with valid attributes' do
        expect(@contact_message).to be_valid
    end

    it 'is not valid without correct phone number format' do
        @contact_message.phone = '123456789'
        expect(@contact_message).to_not be_valid
    end
end