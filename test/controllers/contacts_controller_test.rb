require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = contacts(:one)
  end

  test "should get index" do
    get admin_contacts_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_contact_url
    assert_response :success
  end

  test "should create contact" do
    assert_difference("Contact.count") do
      post admin_contacts_url, params: { contact: {  } }
    end

    assert_redirected_to contact_url(Contact.last)
  end

  test "should show contact" do
    get admin_contact_url(@contact)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_contact_url(@contact)
    assert_response :success
  end

  test "should update contact" do
    patch admin_contact_url(@contact), params: { contact: {  } }
    assert_redirected_to contact_url(@contact)
  end

  test "should destroy contact" do
    assert_difference("Contact.count", -1) do
      delete admin_contact_url(@contact)
    end

    assert_redirected_to admin_contacts_url
  end
end
