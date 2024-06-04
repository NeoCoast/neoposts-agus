# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /show' do
    context 'when the user is not logged in' do
      let(:new_user) { create(:user) }

      before { get user_profile_path(new_user.nickname) }

      it { should redirect_to(new_user_session_path) }
    end

    context 'when the user is logged in' do
      let(:new_user) { create(:user) }
      let!(:created_posts) { create_list(:post, 2, user: new_user) }

      before do
        sign_in new_user
        get user_profile_path(new_user.nickname)
      end

      it 'renders a successful response' do
        expect(response).to be_successful
      end

      it 'includes user first_name' do
        expect(response.body).to include(CGI.escapeHTML(new_user.first_name))
      end

      it 'includes user last_name' do
        expect(response.body).to include(CGI.escapeHTML(new_user.last_name))
      end

      it 'includes user nickname' do
        expect(response.body).to include(CGI.escapeHTML(new_user.nickname))
      end

      it 'includes user birthday' do
        expect(response.body).to include(new_user.birthday.strftime('%m/%d/%Y'))
      end

      it 'includes the user join date' do
        expect(response.body).to include(new_user.created_at.strftime('%m/%d/%Y'))
      end

      it 'includes posts count' do
        expect(response.body).to include(new_user.posts.count.to_s)
      end

      it 'returns all the posts published by the user' do
        posts = controller.instance_variable_get('@posts')
        expect(posts.size).to eq(2)
      end

      it 'includes post 1' do
        expect(response.body).to include(CGI.escapeHTML(created_posts[0].title))
      end

      it 'includes post 2' do
        expect(response.body).to include(CGI.escapeHTML(created_posts[1].title))
      end
    end
  end

  describe 'GET /edit' do
    context 'when the user is not logged in' do
      let(:new_user) { create(:user) }

      before { get edit_user_path(new_user.id) }

      it { should redirect_to(new_user_session_path) }
    end

    context 'when the user is logged in' do
      let(:user1) { create(:user) }

      before do
        sign_in user1
        get edit_user_path(user1.id)
      end

      it 'renders a successful response' do
        expect(response).to be_successful
      end

      context 'with valid attributes update user data' do
        # password remains unchanged
        let(:valid_attributes) do
          attributes_for(:user, password: user1.password, current_password: user1.password)
        end
        before do
          patch user_path(user1.id), params: { user: valid_attributes }
          user1.reload
        end

        it 'edits the user email' do
          expect(user1.email).to eq(valid_attributes[:email])
        end

        it 'edits the user nickname' do
          expect(user1.nickname).to eq(valid_attributes[:nickname])
        end

        it 'edits the user first_name' do
          expect(user1.first_name).to eq(valid_attributes[:first_name])
        end

        it 'edits the user last_name' do
          expect(user1.last_name).to eq(valid_attributes[:last_name])
        end

        it 'edits the user birthday' do
          expect(user1.birthday).to eq(valid_attributes[:birthday])
        end

        it 'redirects to the user profile' do
          expect(response).to redirect_to(user_profile_path(user1.nickname))
        end
      end

      context 'with valid attributes update user password' do
        let(:password) { 'newpassword123' }
        let(:password_confirmation) { 'newpassword123' }
        let(:current_password) { user1.password }

        before do
          patch user_path(user1.id),
                params: { user: { current_password:, password:, password_confirmation: } }
          user1.reload
        end

        it 'updates the user password' do
          expect(user1.valid_password?(password)).to be true
        end

        it 'redirects to the user profile' do
          expect(response).to redirect_to(user_profile_path(user1.nickname))
        end
      end

      context 'with invalid attributes update user data' do
        context 'with blank attributes' do
          let(:invalid_attributes) { attributes_for(:user, :invalid, current_password: user1.password) }

          before do
            patch user_path(user1.id), params: { user: invalid_attributes }
            user1.reload
          end

          it 'returns an unprocessable entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'does not update user email' do
            expect(user1.email).not_to eq(invalid_attributes[:email])
          end

          it 'does not update user nickname' do
            expect(user1.nickname).not_to eq(invalid_attributes[:nickname])
          end

          it 'returns validation errors' do
            expect(response.body).to include(CGI.escapeHTML("can't be blank"))
          end
        end

        context 'with an email that already exists' do
          let(:user2) { create(:user) }
          let(:invalid_attributes) { attributes_for(:user, email: user2.email, current_password: user1.password) }

          before do
            patch user_path(user1.id), params: { user: invalid_attributes }
            user1.reload
          end

          it 'returns an unprocessable entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'does not update user email' do
            expect(user1.email).not_to eq(invalid_attributes[:email])
          end

          it 'returns validation errors' do
            expect(response.body).to include(CGI.escapeHTML('Email has already been taken'))
          end
        end

        context 'with an nickname that already exists' do
          let(:user2) { create(:user) }
          let(:invalid_attributes) { attributes_for(:user, nickname: user2.nickname, current_password: user1.password) }

          before do
            patch user_path(user1.id), params: { user: invalid_attributes }
            user1.reload
          end

          it 'returns an unprocessable entity status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'does not update user email' do
            expect(user1.email).not_to eq(invalid_attributes[:email])
          end

          it 'returns validation errors' do
            expect(response.body).to include(CGI.escapeHTML('Nickname has already been taken'))
          end
        end
      end

      context 'with invalid attributes update user password' do
        context 'with incorrect current_password'
        let(:password) { 'newpassword123' }
        let(:password_confirmation) { 'newpassword123' }
        let(:current_password) { 'incorrectpassword' }

        before do
          patch user_path(user1.id),
                params: { user: { current_password:, password:, password_confirmation: } }
          user1.reload
        end

        it 'returns an unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update the user password' do
          expect(user1.valid_password?(password)).to be false
        end

        context 'with incorrect password confirmation'
        let(:password) { 'newpassword123' }
        let(:password_confirmation) { 'newpassword1234' }
        let(:current_password) { user1.password }

        before do
          patch user_path(user1.id),
                params: { user: { current_password:, password:, password_confirmation: } }
          user1.reload
        end

        it 'returns an unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update the user password' do
          expect(user1.valid_password?(password)).to be false
        end
      end
    end
  end

  describe 'GET /index' do
    context 'when the user is not logged in' do
      before { get users_path }

      it { should redirect_to(new_user_session_path) }
    end

    context 'when the user is logged in' do
      let!(:users_list) { create_list(:user, 2) }

      before do
        sign_in users_list[0]
        get users_path
      end

      it 'renders a successful response' do
        expect(response).to be_successful
      end

      it 'returns all users' do
        users = controller.instance_variable_get('@users')
        expect(users.size).to eq(2)
      end

      it 'includes user 1' do
        expect(response.body).to include(CGI.escapeHTML(users_list[0].nickname))
      end

      it 'includes user 2' do
        expect(response.body).to include(CGI.escapeHTML(users_list[1].nickname))
      end

      context 'when the users list spans more than one page' do
        let!(:users_list) { create_list(:user, 6) }

        before do
          sign_in users_list[0]
        end

        it 'paginates users, showing 5 users in the first page' do
          get users_path(page: 1)
          expect(response.body.scan(/<li id='show-user'[^>]*>/).count).to eq(5)
        end

        it 'paginates users, showing 1 user in the second page' do
          get users_path(page: 2)
          expect(response.body.scan(/<li id='show-user'[^>]*>/).count).to eq(1)
        end
      end
    end
  end
end
