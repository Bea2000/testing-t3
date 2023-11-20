require 'rails_helper'

RSpec.describe 'Products', type: :system do
  before do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com',
                         role: 'admin')
    @owner = User.create!(name: 'John2', password: 'Nonono123!', email: 'das@gmail.com')
    login_as(@user, scope: :user)
    @product = Product.create!(nombre: 'tenis', precio: 4000, stock: 1, user_id: @owner.id, categories: 'Cancha', horarios: 'Lunes,10:00,12:00')
    @product2 = Product.create!(nombre: 'futbol', precio: 4000, stock: 1, user_id: @owner.id, categories: 'Suplementos')
    @review = Review.create!(tittle: 'titulo', description: 'descripcion', calification: 5, product_id: @product.id, user_id: @user.id)
  end
  
  describe 'visiting the product form' do
    it 'have form' do
      visit '/products/crear'
      expect(page).to have_selector('h1', text: 'Crear Producto')
    end

    it 'not allowed on the product form' do
      logout(:user)
      visit '/products/crear'
      expect(page).to have_selector('div', text: 'No estás autorizado para acceder a esta página')
    end
  end

  describe 'listing products' do
    it 'shows page' do
      visit '/products/index'
      expect(page).to have_selector('h1', text: 'Canchas y productos')
    end

    it 'filters products' do
      visit '/products/index'
      expect(page).to have_selector('h1', text: 'Canchas y productos')
      select 'Cancha', from: 'category'
      click_button 'Filtrar'
      expect(page).to have_css('div.card', count: 1)
    end

    it 'filters and searchs products' do
      visit '/products/index'
      expect(page).to have_selector('h1', text: 'Canchas y productos')
      fill_in 'search', with: 'tenis'
      click_button 'Buscar'
      select 'Cancha', from: 'category'
      click_button 'Filtrar'
      expect(page).to have_css('div.card', count: 1)
    end

    it 'searchs products' do
      visit '/products/index'
      expect(page).to have_selector('h1', text: 'Canchas y productos')
      fill_in 'search', with: 'futbol'
      click_button 'Buscar'
      expect(page).to have_css('div.card', count: 1)
    end
  end

  describe 'reading a product' do
    it 'shows details of a product' do
      visit '/products/index'
      expect(page).to have_selector('h1', text: 'Canchas y productos')
      cards = all('.card')
      cards[1].click_link('Detalles')
      expect(page).to have_selector('h1', text: 'Pregúntale al vendedor')
    end
    
    it 'shows details of a product with reviews' do
      visit '/products/index'
      expect(page).to have_selector('h1', text: 'Canchas y productos')
      first('.card').click_link('Detalles')
      expect(page).to have_selector('h1', text: 'Pregúntale al vendedor')
      expect(page).to have_selector('h2', text: 'Calificación promedio')
      expect(page).to have_selector('h1', text: '5.0')
      click_button 'Eliminar reseña'
      expect(page).to have_no_selector('h1', text: '5.0')
    end

    it 'shows details of a product with horarios' do
      visit '/products/index'
      expect(page).to have_selector('h1', text: 'Canchas y productos')
      first('.card').click_link('Detalles')
      expect(page).to have_selector('h1', text: 'Pregúntale al vendedor')
      expect(page).to have_selector('td', text: 'Lunes')
    end
  end

  describe 'adding a product to the wishlist' do
    it 'adds a product to the wishlist' do
      visit '/products/index'
      first('.card').click_link('Detalles')
      click_button 'Guardar en deseados'
      expect(page).to have_selector('div', text: 'Producto agregado a la lista de deseados')
    end

    it 'throws an error when adding a product to the wishlist' do
      allow_any_instance_of(User).to receive(:save).and_return(false)
      visit '/products/index'
      first('.card').click_link('Detalles')
      click_button 'Guardar en deseados'
      expect(page).to have_selector('div', text: 'Hubo un error al guardar los cambios')
    end

    it 'append deseado when deseados is not empty' do
      visit '/products/index'
      @user.deseados = [@product2.id]
      @user.save
      first('.card').click_link('Detalles')
      click_button 'Guardar en deseados'
      expect(page).to have_selector('div', text: 'Producto agregado a la lista de deseados')
    end
  end

  describe 'creating a product' do
    it 'creates a product' do
      visit '/products/crear'
      fill_in 'product[nombre]', with: 'producto'
      fill_in 'product[precio]', with: '4000'
      fill_in 'product[stock]', with: '1'
      select 'Cancha', from: 'product[categories]'
      click_button 'Guardar'
      expect(page).to have_selector('div', text: 'Producto creado Correctamente !')
    end

    it 'throws an error when creating a product' do
      allow_any_instance_of(Product).to receive(:save).and_return(false)
      visit '/products/crear'
      fill_in 'product[nombre]', with: 'producto'
      fill_in 'product[precio]', with: '4000'
      fill_in 'product[stock]', with: '1'
      select 'Cancha', from: 'product[categories]'
      click_button 'Guardar'
      expect(page).to have_selector('div', text: 'Hubo un error al guardar el producto')
    end

    it 'throws an error when creating a product without name' do
      visit '/products/crear'
      fill_in 'product[precio]', with: '4000'
      fill_in 'product[stock]', with: '1'
      select 'Cancha', from: 'product[categories]'
      click_button 'Guardar'
      expect(page).to have_selector('div', text: 'Hubo un error al guardar el producto')
    end

    it 'throws an error when creating a product without price' do
      visit '/products/crear'
      fill_in 'product[nombre]', with: 'producto'
      fill_in 'product[stock]', with: '1'
      select 'Cancha', from: 'product[categories]'
      click_button 'Guardar'
      expect(page).to have_selector('div', text: 'Hubo un error al guardar el producto')
    end

    it 'throws an error when creating a product without stock' do
      visit '/products/crear'
      fill_in 'product[nombre]', with: 'producto'
      fill_in 'product[precio]', with: '4000'
      select 'Cancha', from: 'product[categories]'
      click_button 'Guardar'
      expect(page).to have_selector('div', text: 'Hubo un error al guardar el producto')
    end

    it 'throws an error when creating a product with negative stock' do
      visit '/products/crear'
      fill_in 'product[nombre]', with: 'producto'
      fill_in 'product[precio]', with: '4000'
      fill_in 'product[stock]', with: '-1'
      select 'Cancha', from: 'product[categories]'
      click_button 'Guardar'
      expect(page).to have_selector('div', text: 'Hubo un error al guardar el producto')
    end

    it 'throws an error when creating a product with negative price' do
      visit '/products/crear'
      fill_in 'product[nombre]', with: 'producto'
      fill_in 'product[precio]', with: '-4000'
      fill_in 'product[stock]', with: '1'
      select 'Cancha', from: 'product[categories]'
      click_button 'Guardar'
      expect(page).to have_selector('div', text: 'Hubo un error al guardar el producto')
    end
  end


end
