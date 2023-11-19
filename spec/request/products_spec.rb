require 'rails_helper'

RSpec.describe 'Products', type: :request do
  before do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com',
                         role: 'admin')
    @owner = User.create!(name: 'John2', password: 'Nonono123!', email: 'bea@gmail.com')
    @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
    @product2 = Product.create!(nombre: 'John2', precio: 4000, stock: 1, user_id: @owner.id, categories: 'Suplementos')
    sign_in @user
  end
  describe 'GET /new' do
    it 'returns http success' do
      get '/products/index'
      expect(response).to have_http_status(:success)
    end
    it 'return http success without login' do
      sign_out @user
      get '/products/index'
      expect(response).to have_http_status(:success)
    end

    it 'return http success with search and category present' do
      get '/products/index', params: { search: 'John1', category: 'Cancha' }
      expect(response).to have_http_status(:success)
    end

  end

  describe 'GET /crear' do
    it 'redirects when not adminsitrator' do
      sign_out @user
      get '/products/crear'
      expect(response).to redirect_to('/')
    end

    it 'redirects when not administrator and accesing database' do
      sign_out @user
      sign_in @owner
      post '/products/insertar', params: { product: { nombre: 'John1', precio: 4000, stock: 1, user_id: @owner.id, categories: 'Cancha' } }
      expect(response).to redirect_to('/products/index')
    end
  end

  describe 'GET /actualizar' do
    it 'redirects when administrator' do
      patch "/products/actualizar/#{@product.id}", params: { product: { nombre: 'John1', precio: 4000, stock: 1, user_id: @owner.id, categories: 'Cancha' } }
      expect(response).to redirect_to('/products/index')
    end

    it 'redirects when not administrator' do
      sign_out @user
      sign_in @owner
      patch  "/products/actualizar/#{@product2.id}" , params: { product: { nombre: '' }}
      expect(response).to redirect_to("/products/index")
      expect(flash[:alert]).to eq('Debes ser un administrador para modificar un producto.')
    end

    it 'redirects when failed request' do
      patch  "/products/actualizar/#{@product2.id}" , params: { product: { nombre: '' }}
      expect(response).to redirect_to("/products/actualizar/#{@product2.id}")
      expect(flash[:error]).to eq('Hubo un error al guardar el producto. Complete todos los campos solicitados!')
    end

    it 'return product to update' do
      sign_out @user
      sign_in @owner
      get "/products/actualizar/#{@product2.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /eliminar' do
    it 'redirects when not administrator' do
      sign_out @user
      sign_in @owner
      delete "/products/eliminar/#{@product2.id}"
      expect(flash[:alert]).to eq('Debes ser un administrador para eliminar un producto.')
    end

    it 'redirects when administrator and destroy product' do
      delete "/products/eliminar/#{@product2.id}"
      expect(response).to redirect_to('/products/index')
      expect(Product.exists?(@product2.id)).to be_falsey
    end
  end
end
