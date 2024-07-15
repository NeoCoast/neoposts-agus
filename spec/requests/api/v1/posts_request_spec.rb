# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  describe 'GET /index' do
    let(:new_user) { create(:user) }

    context 'when the user is not logged in' do
      before { get api_v1_user_posts_path(new_user.id) }

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
      let!(:posts_list) { create_list(:post, 2, user: new_user) }
      let(:client) do
        post api_user_session_path, params: { email: new_user.email, password: new_user.password }.to_json,
                                    headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        request.headers['client']
      end
      let(:new_auth_header) { new_user.create_new_auth_token(client) }

      context 'when the user in the request exist' do
        before do
          get api_v1_user_posts_path(new_user.id), headers: new_auth_header
        end

        it 'renders a successful response' do
          expect(response).to be_successful
        end

        it 'returns a json response' do
          expect(response.content_type).to eq 'application/json; charset=utf-8'
        end

        it "returns all user's posts" do
          json_response = JSON.parse(response.body)
          expect(json_response.size).to eq(2)
        end

        it 'includes post 1' do
          expect(response.body).to include(posts_list[0].title)
        end

        it 'includes post 2' do
          expect(response.body).to include(posts_list[1].title)
        end

        it 'contains expected attributes in the JSON response' do
          json_response = JSON.parse(response.body)
          expect(json_response.first.keys).to match_array(%w[id title body published_at user_id
                                                             likes_count comments_count])
        end
      end

      context 'when the user in the request does not exist' do
        before do
          get api_v1_user_posts_path(0), headers: new_auth_header
        end

        it 'returns 404 not found' do
          expect(response).to have_http_status(:not_found)
        end

        it 'returns a json response' do
          expect(response.content_type).to eq 'application/json; charset=utf-8'
        end

        it 'returns a not found error message' do
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to eq('User not found.')
        end
      end
    end
  end

  describe 'GET /show' do
    let(:new_user) { create(:user) }
    let(:new_post) { create(:post) }

    context 'when the user is not logged in' do
      before { get api_v1_post_path(new_post.id) }

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
      let(:client) do
        post api_user_session_path, params: { email: new_user.email, password: new_user.password }.to_json,
                                    headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        request.headers['client']
      end
      let(:new_auth_header) { new_user.create_new_auth_token(client) }

      context 'when the post exists' do
        let!(:new_like) { create(:like, :likeable_type_post, likeable: new_post) }
        let!(:new_comment) { create(:comment_of_post, commentable: new_post) }

        before do
          get api_v1_post_path(new_post.id), headers: new_auth_header
        end

        it 'renders a successful response' do
          expect(response).to be_successful
        end

        it 'returns a json response' do
          expect(response.content_type).to eq 'application/json; charset=utf-8'
        end

        it 'contains expected attributes in the JSON response' do
          json_response = JSON.parse(response.body)
          expect(json_response.keys).to match_array(%w[id title body published_at user_id
                                                       likes comments])
          expect(json_response['likes'].first.keys).to match_array(%w[user_id nickname])
          expect(json_response['comments'].first.keys).to match_array(%w[id content replies])
        end
      end

      context 'when the post in the request does not exist' do
        before do
          get api_v1_post_path(0), headers: new_auth_header
        end

        it 'returns 404 not found' do
          expect(response).to have_http_status(:not_found)
        end

        it 'returns a json response' do
          expect(response.content_type).to eq 'application/json; charset=utf-8'
        end

        it 'returns a not found error message' do
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to eq('Post not found.')
        end
      end
    end
  end

  describe 'POST /create' do
    let(:new_user) { create(:user) }

    context 'when the user is not logged in' do
      before { post api_v1_user_posts_path(new_user.id) }

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
      let(:client) do
        post api_user_session_path, params: { email: new_user.email, password: new_user.password }.to_json,
                                    headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        request.headers['client']
      end
      let(:new_auth_header) { new_user.create_new_auth_token(client) }

      context 'with valid attributes' do
        let!(:valid_attributes) { attributes_for(:post) }

        context 'when the user in the request exist' do
          context 'when the post is created for the logged user' do
            before do
              post api_v1_user_posts_path(new_user.id), params: valid_attributes, headers: new_auth_header
            end

            it 'renders a successful response' do
              JSON.parse(response.body)
              expect(response).to be_successful
            end

            it 'returns a json response' do
              expect(response.content_type).to eq 'application/json; charset=utf-8'
            end

            it 'contains expected attributes in the JSON response' do
              json_response = JSON.parse(response.body)
              expect(json_response.keys).to match_array(%w[id title body published_at user_id likes_count
                                                           comments_count])
            end
          end

          context 'when the post is created for another user' do
            let!(:new_user2) { create(:user) }

            before do
              post api_v1_user_posts_path(new_user2.id), params: valid_attributes, headers: new_auth_header
            end

            it 'returns 403 Forbidden' do
              expect(response).to have_http_status(:forbidden)
            end

            it 'returns a json response' do
              expect(response.content_type).to eq 'application/json; charset=utf-8'
            end

            it 'returns an error message when trying to create a post for another user' do
              json_response = JSON.parse(response.body)
              expect(json_response).to have_key('errors')
              expect(json_response['errors']).to eq(['You can only create a post for yourself.'])
            end
          end
        end

        context 'when the user in the request does not exist' do
          before do
            post api_v1_user_posts_path(0), params: valid_attributes, headers: new_auth_header
          end

          it 'returns 404 not found' do
            expect(response).to have_http_status(:not_found)
          end

          it 'returns a json response' do
            expect(response.content_type).to eq 'application/json; charset=utf-8'
          end

          it 'returns a not found error message' do
            json_response = JSON.parse(response.body)
            expect(json_response).to have_key('error')
            expect(json_response['error']).to eq('User not found.')
          end
        end
      end

      context 'with invalid attributes' do
        let!(:invalid_attributes) { attributes_for(:post, :invalid) }
        before do
          post api_v1_user_posts_path(new_user.id), params: invalid_attributes, headers: new_auth_header
        end

        it 'returns 422 Unprocessable Content' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns a json response' do
          expect(response.content_type).to eq 'application/json; charset=utf-8'
        end

        it 'returns error messages for invalid post attributes' do
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('errors')
          expect(json_response['errors']).to eq(["Title can't be blank", "Body can't be blank"])
        end
      end
    end
  end
end
