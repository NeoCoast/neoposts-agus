# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /show' do
    context 'when the user is not logged in' do
      let(:new_user) { create(:user) }

      before { get user_path(new_user.nickname) }

      it { should redirect_to(new_user_session_path) }
    end

    context 'when the user is logged in' do
      let(:new_user) { create(:user) }
      let!(:created_posts) { create_list(:post, 2, user: new_user) }

      before do
        sign_in new_user
        get user_path(new_user.nickname)
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
end
