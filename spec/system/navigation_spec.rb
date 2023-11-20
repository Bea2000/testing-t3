require 'rails_helper'

RSpec.describe 'Navigation', type: :system do
    before do
        @user = User.create!(name: 'John1', password: 'JohnDoe', email: 'johndoe@gmail.com')
        @owner = User.create!(name: 'JohnAdmin', password: 'JohnDoeAdmin', email: 'johndoe@admin.com')
        login_as(@user, scope: :user)
        @product1 = Product.create!(nombre: 'tenis', precio: 4000, stock: 1, user_id: @owner.id, categories: 'Cancha', horarios: 'Lunes,10:00,12:00')
        @product2 = Product.create!(nombre: 'futbol', precio: 6000, stock: 1, user_id: @owner.id, categories: 'Suplementos')
        @review = Review.create!(tittle: 'titulo', description: 'descripcion', calification: 5, product_id: @product1.id, user_id: @user.id)
    end

    describe 'navigation from "Inicio" with logued user' do
        it 'navigates to "Canchas y productos" and then to "Contacto"' do
            visit '/products/index'
            expect(page).to have_selector('h1', text: 'Canchas y productos')
            click_link 'Contacto'
            expect(page).to have_selector('h1', text: 'Contacto')
        end

        it 'navigates to "Canchas y productos" and then to "Mi carrito"' do
            visit '/products/index'
            expect(page).to have_selector('h1', text: 'Canchas y productos')
            click_link 'Mi carrito'
            expect(page).to have_selector('h1', text: 'Tu carrito de compras')
        end

        it 'navigates to "Canchas y productos" and then to "Mi cuenta"' do
            visit '/products/index'
            expect(page).to have_selector('h1', text: 'Canchas y productos')
            click_link 'Mi cuenta'
            expect(page).to have_selector('h2', text: 'Mis datos')
        end
    end

    describe 'navigation from "Inicio" witout logued user' do
        it 'navigate to "Inicio" and then to "Canchas y productos" and then to "Detalles" and then to "Dejar una reseña"' do
            logout(:user)
            visit '/'
            expect(page).to have_selector('p', text: 'Ejercita. Juega. Disfruta.')
            visit '/products/index'
            expect(page).to have_selector('h1', text: 'Canchas y productos')
            cards = all('.card')
            cards[1].click_link('Detalles')
            expect(page).to have_selector('h1', text: 'Pregúntale al vendedor')
            click_button 'Dejar una reseña'
            expect(page).to have_selector('div', text: 'Debes iniciar sesión para dejar una reseña.')

        end

        it 'navigate to "Inicio" and then to "Contacto"' do
            logout(:user)
            visit '/'
            expect(page).to have_selector('p', text: 'Ejercita. Juega. Disfruta.')
            visit '/contacto'
            expect(page).to have_selector('h1', text: 'Contacto')
        end

        it 'navigate to "Inicio" and then to "Mi carrito"' do
            logout(:user)
            visit '/'
            expect(page).to have_selector('p', text: 'Ejercita. Juega. Disfruta.')
            visit '/carro'
            expect(page).to have_selector('p', text: 'Debes iniciar sesión para ver tu carrito de compras')
        end

        it 'navigate to "Inicio" and then to "Iniciar Sesión" and then click in button "Iniciar Sesión"' do
            logout(:user)
            visit '/'
            expect(page).to have_selector('p', text: 'Ejercita. Juega. Disfruta.')
            visit '/login'
            expect(page).to have_selector('h2', text: 'Iniciar Sesión')
            click_button 'Iniciar Sesión'
            expect(page).to have_selector('div', text: 'Email o contraseña no válida.')
        end

        it 'navigate to "Inicio" and then to "Regístrate"' do
            logout(:user)
            visit '/'
            expect(page).to have_selector('p', text: 'Ejercita. Juega. Disfruta.')
            visit '/register'
            expect(page).to have_selector('h2', text: 'Registro')
        end
    end
end