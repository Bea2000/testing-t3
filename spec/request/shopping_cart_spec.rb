require 'rails_helper'

RSpec.describe ShoppingCart, type: :request do
    before do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'df@uc.cl', role: 'admin')
        @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1000, user_id: @user.id, categories: 'Cancha')
        sign_in @user
    end

    describe 'GET /show' do
        it 'renders a successful response' do
            get '/carro'
            expect(response).to be_successful
        end

        it 'redirects when failed to create shopping cart' do
            allow_any_instance_of(ShoppingCart).to receive(:save).and_return(false)
            get '/carro'
            expect(flash[:alert]).to eq('Hubo un error al crear el carro. Contacte un administrador.')
            expect(response).to redirect_to('/')
        end
    end

    describe 'GET /details' do
        it 'redirects back when user is not logged in' do
            sign_out @user
            get '/carro/detalle'
            expect(response).to redirect_to('/')
        end

        it 'redirect when there arent products in the shopping cart' do
            get '/carro/detalle'
            expect(flash[:alert]).to eq('No tienes productos que comprar.')
            expect(response).to redirect_to('/carro')
        end

        it 'renders a successful response when there are products in the shopping cart' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {@product.id => 1})
            get '/carro/detalle'
            total_pago = assigns(:total_pago)
            expect(total_pago).to eq(5200)
            expect(response).to be_successful
        end
    end

    describe 'POST /insertar_producto' do
        it 'redirects back when user is not logged in' do
            sign_out @user
            post '/carro/insertar_producto', params: { product_id: @product.id, amount: 1 }
            expect(response).to redirect_to('/carro')
            expect(flash[:alert]).to eq('Debes iniciar sesión para agregar productos al carro de compras.')
        end

        it 'sums amount when product already exists' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {@product.id => 1})
            post '/carro/insertar_producto', params: { product_id: @product.id, add: {amount: 1} }
            products = assigns(:shopping_cart).products
            products = products.transform_keys(&:to_i)
            expect(products[@product.id]).to eq(2)
            expect(response).to redirect_to('/')
        end

        it 'creates a new product when it doesnt exist' do
            post '/carro/insertar_producto', params: { product_id: @product.id, add: {amount: 1} }
            products = assigns(:shopping_cart).products
            products = products.transform_keys(&:to_i)
            expect(products[@product.id]).to eq(1)
            expect(response).to redirect_to('/')
        end

        it 'redirects back when there are more than 8 products in the shopping cart' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {@product.id => 1})
            8.times do
                product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
                post '/carro/insertar_producto', params: { product_id: product.id, add: {amount: 1} }
            end
            expect(flash[:alert]).to eq('Has alcanzado el máximo de productos en el carro de compras (8). Elimina productos para agregar más o realiza el pago de los productos actuales.')
            expect(response).to redirect_to('/')
        end

        it 'redirects back when there are more than 100 of a product' do
            post '/carro/insertar_producto', params: { product_id: @product.id, add: {amount: 101} }
            expect(flash[:alert]).to eq("El producto '#{@product.nombre}' tiene un máximo de 100 unidades por compra.")
            expect(response).to redirect_to('/')
        end

        it 'redirects back when there is not enough stock' do
            post '/carro/insertar_producto', params: { product_id: @product.id, add: {amount: 1001} }
            expect(flash[:alert]).to eq("El producto '#{@product.nombre}' no tiene suficiente stock para agregarlo al carro de compras.")
            expect(response).to redirect_to('/')
        end

        it 'redirects to /carro/detalle when buy_now is true' do
            post '/carro/comprar_ahora', params: { product_id: @product.id, add: {amount: 1} }
            expect(response).to redirect_to('/carro/detalle')
        end

        it 'redirects back when failed request' do
            allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
            post '/carro/insertar_producto', params: { product_id: @product.id, add: {amount:  ''} }
            expect(flash[:notice]).to be_nil
            expect(flash[:alert]).to eq('Hubo un error al agregar el producto al carro de compras')
        end

        it 'redirect to /carro when not logged in' do
            sign_out @user
            post '/carro/insertar_producto', params: { product_id: @product.id, add: {amount: 1} }
            expect(flash[:alert]).to eq('Debes iniciar sesión para agregar productos al carro de compras.')
            expect(response).to redirect_to('/carro')
        end
    end

    describe 'POST /eliminar_producto' do
        it 'redirects to /carro when product doesnt exist' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {})
            delete "/carro/eliminar_producto/#{@product.id}"
            expect(flash[:alert]).to eq('El producto no existe en el carro de compras')
            expect(response).to redirect_to('/carro')
        end

        it 'redirects to /carro when failed request' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {@product.id => 1})
            allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
            delete "/carro/eliminar_producto/#{@product.id}"
            expect(flash[:alert]).to eq('Hubo un error al eliminar el producto del carro de compras')
            expect(response).to redirect_to('/carro')
        end

        it 'redirects to /carro when successful request' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {@product.id => 1})
            delete "/carro/eliminar_producto/#{@product.id}"
            expect(flash[:notice]).to eq('Producto eliminado del carro de compras')
            expect(response).to redirect_to('/carro')
        end
    end

    describe 'POST /realizar_compra' do
        it 'redirects to /carro when there arent products in the shopping cart' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {})
            post '/carro/realizar_compra'
            expect(flash[:alert]).to eq('No tienes productos en el carro de compras')
            expect(response).to redirect_to('/carro')
        end

        it 'redirects when shopping cart doesnt exist' do
            post '/carro/realizar_compra'
            expect(flash[:alert]).to eq('No se encontró tu carro de compras. Contacte un administrador.')
            expect(response).to redirect_to('/carro')
        end

        it 'redirects to /carro when not enough stock' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {@product.id => 1001})
            post '/carro/realizar_compra'
            expect(flash[:alert]).to eq("Compra cancelada: El producto '#{@product.nombre}' no tiene suficiente stock para realizar la compra. " \
            'Por favor, elimina el producto del carro de compras o reduce la cantidad.')
            expect(response).to redirect_to('/carro')
        end

        it 'redirects when failed request' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {@product.id => 1})
            allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
            post '/carro/realizar_compra'
            expect(flash[:alert]).to eq('Hubo un error al actualizar el carro. Contacte un administrador.')
            expect(response).to redirect_to('/carro')
        end

        it 'redirects to /solicitud/index when successful request' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {@product.id => 1})
            post '/carro/realizar_compra'
            expect(flash[:notice]).to eq('Compra realizada exitosamente')
            expect(response).to redirect_to('/solicitud/index')
        end

        it 'redirects to /carro when failed to create a Solicitud' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {@product.id => 1})
            allow_any_instance_of(Solicitud).to receive(:save).and_return(false)
            post '/carro/realizar_compra'
            expect(flash[:alert]).to eq('Hubo un error al realizar la compra. Contacte un administrador.')
            expect(response).to redirect_to('/carro')
        end

    end

    describe 'DELETE /limpiar' do
        it 'redirects to /carro when failed request' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {@product.id => 1})
            allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
            delete '/carro/limpiar'
            expect(flash[:alert]).to eq('Hubo un error al limpiar el carro de compras. Contacte un administrador.')
            expect(response).to redirect_to('/carro')
        end

        it 'redirects to /carro when successful request' do
            @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {@product.id => 1})
            delete '/carro/limpiar'
            expect(flash[:notice]).to eq('Carro de compras limpiado exitosamente')
            expect(response).to redirect_to('/carro')
        end
    end

end