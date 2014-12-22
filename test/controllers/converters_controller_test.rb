require 'test_helper'

class ConvertersControllerTest < ActionController::TestCase
  setup do
    @converters = converters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:converters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create converter" do
    assert_difference('Converter.count') do
      post :create, converter: { bibid: @converters.bibid, marcxml: @converters.marcxml, bibframe: @converters.bibframe }
    end

    assert_redirected_to converter_path(assigns(:converter))
  end

  test "should show converter" do
    get :show, id: @converters
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @converters
    assert_response :success
  end

  test "should update converter" do
    patch :update, id: @converters, converter: { bibid: @converters.bibid, marcxml: @converters.marcxml, bibframe: @converters.bibframe }
    assert_redirected_to converter_path(assigns(:converter))
  end

  test "should destroy converter" do
    assert_difference('Converter.count', -1) do
      delete :destroy, id: @converters
    end

    assert_redirected_to converters_path
  end
end
