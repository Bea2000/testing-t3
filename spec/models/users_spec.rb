require 'rails_helper'

RSpec.describe User, type: :model do
  before(:each) do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
    @user2 =  User.new(name: 'John2', password: 'ValidPassword123', email: 'bea@gmail.com', role: 'normal')
    @user3 =  User.new(name: 'John3', password: '', email: 'bea2@gmail.com', role: 'normal')
    @Product = Product.create!(nombre: 'tenis', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
  end

  it 'is valid with valid attributes' do
    expect(@user).to be_valid
  end

  it 'should return admin true' do
    expect(@user.admin?).to be true
  end

  it 'should return admin false' do
    expect(@user2.admin?).to be false
  end

  it 'should return nil when password is valid' do
    expect(@user.validate_password_strength).to be_nil
  end

  it 'should return an error message when password is invalid' do
    @user2.validate_password_strength
    expect(@user2.errors.full_messages[0]).to eq("Password: no es válido incluir como minimo una mayuscula, minuscula y un simbolo")
  end

  it 'should return nil when password is blank' do
    expect(@user3.validate_password_strength).to be_nil
  end

    it 'should return nil when deseados is valid' do
    @user2.deseados = [@Product.id]
    expect(@user2.validate_new_wish_product).to be_nil
  end

    it 'should return an error message when deseados is invalid' do
    @user.deseados = ['tenis2']
    @user.validate_new_wish_product
    expect(@user.errors.full_messages[0]).to eq("Deseados: el articulo que se quiere ingresar a la lista de deseados no es valido")
  end

    it 'should return nil when deseados is empty' do
    expect(@user3.validate_new_wish_product).to be_nil
  end

  it 'should return an error when passwords dont match' do
    @user2.password = 'ValidPassword123'
    @user2.password_confirmation = 'ValidPassword1234'
    @user2.valid?
    expect(@user2.errors.full_messages[0]).to eq("Password confirmation: no coincide")
  end

  it 'should return an error if mail is blank' do
    @user2.email = ''
    @user2.valid?
    expect(@user2.errors.full_messages[0]).to eq("Email: no puede estar en blanco")
  end

  it 'should return an error if mail doesnt exist' do
    @user2.email = 'holi'
    @user2.valid?
    expect(@user2.errors.full_messages[0]).to eq("Email: no es válido")
  end

end
