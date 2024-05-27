# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'GET /new' do
    context 'when the user is not logged in' do
      before { get new_post_path }

      it { should redirect_to(new_user_session_path) }
    end

    context 'when the user is logged in' do
      let(:new_user) { create(:user) }

      before do
        sign_in new_user
        get new_post_path
      end

      it 'renders a successful response' do
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /show' do
    context 'when the user is not logged in' do
      let(:new_post) { create(:post) }

      before { get post_path(new_post.id) }

      it { should redirect_to(new_user_session_path) }
    end

    context 'when the user is logged in' do
      let(:new_post) { create(:post) }

      before do
        sign_in new_post.user
        get post_path(new_post.id)
      end

      it 'renders a successful response' do
        expect(response).to be_successful
      end

      it 'includes post title' do
        expect(response.body).to include(CGI.escapeHTML(new_post.title))
      end

      it 'includes post body' do
        expect(response.body).to include(CGI.escapeHTML(new_post.body))
      end
    end
  end

  describe 'POST /create' do
    context 'when the user is not logged in' do
      before { post posts_path }

      it { should redirect_to(new_user_session_path) }
    end

    context 'when the user is logged in' do
      let(:new_user) { create(:user) }

      before do
        sign_in new_user
      end

      context 'with valid attributes' do
        let(:valid_attributes) { attributes_for(:post) }

        it 'creates a new post' do
          expect do
            post posts_path, params: { post: valid_attributes }
          end.to change(Post, :count).by(1)
        end

        before { post posts_path, params: { post: valid_attributes } }

        it 'redirects to the new post' do
          expect(response).to redirect_to(post_path(Post.last))
        end
      end

      context 'with invalid attributes' do
        let(:invalid_attributes) { attributes_for(:post, :invalid) }

        it 'does not create a new post' do
          expect do
            post posts_path, params: { post: invalid_attributes }
          end.to change(Post, :count).by(0)
        end

        before { post posts_path, params: { post: invalid_attributes } }

        it 'returns an unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns validation errors' do
          expect(response.body).to include('Please enter')
        end
      end
    end
  end

  describe 'GET /index' do
    context 'when the user is not logged in' do
      before { get posts_path }

      it { should redirect_to(new_user_session_path) }
    end

    context 'when the user is logged in' do
      let(:post1) { create(:post) }
      let(:post2) { create(:post) }

      before do
        sign_in post1.user
        post2
        get posts_path
      end

      it 'renders a successful response' do
        expect(response).to be_successful
      end

      it 'returns all posts' do
        expect(response.body).to include(CGI.escapeHTML(post1.title))
        expect(response.body).to include(CGI.escapeHTML(post2.title))
      end

      it 'returns posts ordered by newest' do
        posts = controller.instance_variable_get('@posts')
        expect(posts.size).to eq(2)
        expect(posts.first.title).to eq(post2.title) # newest first
        expect(posts.second.title).to eq(post1.title)
      end
    end
  end
end
