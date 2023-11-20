require 'rails_helper'

RSpec.describe 'Contact Message', type: :system do
  before do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'df@uc.cl')
    login_as(@user, scope: :user)
  end

  describe 'leaving a contact message' do
    it 'leaves a contact message' do
      visit '/contacto'
      fill_in 'contact[name]', with: 'nombre'
      fill_in 'contact[mail]', with: 'email@uc.cl'
      fill_in 'contact[title]', with: 'titulo'
      fill_in 'contact[phone]', with: '+56977743528'
      fill_in 'contact[body]', with: 'mensaje'
      click_button 'Enviar'
      expect(page).to have_selector('div', text: 'Mensaje de contacto enviado correctamente')
    end

    it 'throws an error when leaving a contact message' do
      allow_any_instance_of(ContactMessage).to receive(:save).and_return(false)
      visit '/contacto'
      fill_in 'contact[name]', with: 'nombre'
      fill_in 'contact[mail]', with: 'fs@uc.cl'
      fill_in 'contact[title]', with: 'titulo'
      fill_in 'contact[phone]', with: '+56977743528'
      fill_in 'contact[body]', with: 'mensaje'
      click_button 'Enviar'
      expect(page).not_to have_selector('div', text: 'Mensaje de contacto enviado correctamente')
    end

    it 'throws and error when incorrect phone format' do
        visit '/contacto'
        fill_in 'contact[name]', with: 'nombre'
        fill_in 'contact[mail]', with: 'd@uc.cl'
        fill_in 'contact[title]', with: 'titulo'
        fill_in 'contact[phone]', with: '77743528'
        fill_in 'contact[body]', with: 'mensaje'
        click_button 'Enviar'
        expect(page).to have_selector('div', text: 'El formato del teléfono debe ser +56XXXXXXXXX')
    end

    it 'doesnt send when incorrect mail format' do
        visit '/contacto'
        fill_in 'contact[name]', with: 'nombre'
        fill_in 'contact[mail]', with: 'dc'
        fill_in 'contact[title]', with: 'titulo'
        fill_in 'contact[phone]', with: '+56977743528'
        fill_in 'contact[body]', with: 'mensaje'
        click_button 'Enviar'
        expect(page).not_to have_selector('div', text: 'Mensaje de contacto enviado correctamente')
    end
  end
end