require 'test_helper'

class RequestHandlerTest < ActionDispatch::IntegrationTest
  test "process_request should handle ActionController::RoutingError" do
    data = {
      remote_ip: '127.0.0.1',
      url: '/non_existent_route',
      status_code: 404
    }

    assert_no_difference('SpamRequest.count') do
      post '/notify', params: data
    end

    assert_response :not_found
  end

  test "process_request should block malicious endpoints" do
    data = {
      remote_ip: '127.0.0.1',
      url: '/wp-admin',
      status_code: 404
    }

    post '/notify', params: data

    assert_response :not_found
    assert_equal true, Rails.cache.read("blocked_#{data[:remote_ip]}")
  end
end
