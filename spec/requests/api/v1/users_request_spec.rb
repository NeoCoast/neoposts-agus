# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /api/v1/users' do
    context 'when the user is not logged in' do
      before { get api_v1_users_path }

      it 'returns 401 Unauthorized' do
        expect(response.status).to eq(401)
      end

      it 'indicates authentication is required' do
        expect(response.body).to include(CGI.escapeHTML('You need to sign in or sign up before continuing.'))
      end

      it 'returns a json response' do
        expect(response.content_type).to eq 'application/json; charset=utf-8'
      end
    end

    context 'when the user is logged in' do
      let!(:users_list) { create_list(:user, 2) }
      let!(:client) do
        post api_user_session_path, params: { email: users_list[0].email, password: users_list[0].password }.to_json,
                                    headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        request.headers['client']
      end
      let!(:new_auth_header) { users_list[0].create_new_auth_token(client) }

      before do
        get api_v1_users_path, headers: new_auth_header
      end

      it 'renders a successful response' do
        expect(response).to be_successful
      end

      it 'returns all users' do
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(2)
      end

      it 'includes user 1' do
        expect(response.body).to include(CGI.escapeHTML(users_list[0].nickname))
      end

      it 'includes user 2' do
        expect(response.body).to include(CGI.escapeHTML(users_list[1].nickname))
      end

      it 'contains expected attributes in the JSON response' do
        json_response = JSON.parse(response.body)
        expect(json_response.first.keys).to match_array(%w[id email nickname first_name last_name birthday])
      end
    end
  end
end
