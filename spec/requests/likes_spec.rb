# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Likes', type: :request do
  describe 'POST /create' do
    let(:new_user) { create(:user) }
    let(:new_post) { create(:post) }

    context 'when the user is not logged in' do
      let(:params) do
        { likeable_type: new_post.class.name, likeable_id: new_post.id }
      end

      before { post likes_path, params:, xhr: true }

      it 'returns 401 Unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is logged in' do
      before { sign_in new_user }

      context 'when it is a like on a post' do
        let(:params) do
          { likeable_type: new_post.class.name, likeable_id: new_post.id }
        end

        it 'creates a like' do
          expect do
            post likes_path, params:, xhr: true
          end.to change(Like, :count).by(1)
        end

        it 'responds with success' do
          post likes_path, params:, xhr: true
          expect(response).to have_http_status(:success)
        end

        it 'renders unlike form' do
          post likes_path, params:, xhr: true
          expect(response.body).to include(CGI.escapeHTML('bi-heart-fill'))
        end

        it 'renders increased likes count' do
          post likes_path, params:, xhr: true
          expect(response.body).to include(CGI.escapeHTML((new_post.likes_count + 1).to_s))
        end
      end

      context 'when it is a like on a comment' do
        let!(:new_comment) { create(:comment_of_post) }

        let(:params) do
          { likeable_type: new_comment.class.name, likeable_id: new_comment.id }
        end

        it 'creates a like' do
          expect do
            post likes_path, params:, xhr: true
          end.to change(Like, :count).by(1)
        end

        it 'responds with success' do
          post likes_path, params:, xhr: true
          expect(response).to have_http_status(:success)
        end

        it 'renders unlike form' do
          post likes_path, params:, xhr: true
          expect(response.body).to include(CGI.escapeHTML('bi-heart-fill'))
        end

        it 'renders increased likes count' do
          post likes_path, params:, xhr: true
          expect(response.body).to include(CGI.escapeHTML((new_comment.likes_count + 1).to_s))
        end
      end

      context 'when no valid likeable is provided' do
        let(:params) do
          { likeable_type: new_post.class.name, likeable_id: '' }
        end

        it 'does not create a like' do
          expect do
            post likes_path, params:, xhr: true
          end.to change(Like, :count).by(0)
        end
      end

      context 'when the likeable is already liked' do
        let!(:new_like) { create(:like, :likeable_type_post, user: new_user, likeable: new_post) }
        let(:params) do
          { likeable_type: new_post.class.name, likeable_id: new_post.id }
        end

        it 'does not create a like' do
          expect do
            post likes_path, params:, xhr: true
          end.to change(Like, :count).by(0)
        end
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:new_user) { create(:user) }
    let!(:post_like) { create(:like, :likeable_type_post, user: new_user) }

    context 'when the user is not logged in' do
      before { delete like_path(id: post_like.id), xhr: true }

      it 'returns 401 Unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is logged in' do
      before { sign_in new_user }

      context 'when it is a like on a post' do
        it 'deletes a like' do
          expect do
            delete like_path(id: post_like.id), xhr: true
          end.to change(Like, :count).by(-1)
        end

        it 'responds with success' do
          delete like_path(id: post_like.id), xhr: true
          expect(response).to have_http_status(:success)
        end

        it 'renders like form' do
          delete like_path(id: post_like.id), xhr: true
          expect(response.body).to include(CGI.escapeHTML('bi-heart'))
        end

        it 'renders decreased likes count' do
          delete like_path(id: post_like.id), xhr: true
          expect(response.body).to include(CGI.escapeHTML((post_like.likeable.likes_count - 1).to_s))
        end
      end

      context 'when it is a like on a comment' do
        let!(:comment_like) { create(:like, :likeable_type_comment, user: new_user) }

        it 'deletes a like' do
          expect do
            delete like_path(id: comment_like.id), xhr: true
          end.to change(Like, :count).by(-1)
        end

        it 'responds with success' do
          delete like_path(id: comment_like.id), xhr: true
          expect(response).to have_http_status(:success)
        end

        it 'renders like form' do
          delete like_path(id: comment_like.id), xhr: true
          expect(response.body).to include(CGI.escapeHTML('bi-heart'))
        end

        it 'renders decreased likes count' do
          delete like_path(id: comment_like.id), xhr: true
          expect(response.body).to include(CGI.escapeHTML((comment_like.likeable.likes_count - 1).to_s))
        end
      end

      context 'when no valid id is provided' do
        it 'does not delete a like' do
          expect do
            delete like_path(id: 0), xhr: true
          end.to change(Like, :count).by(0)
        end
      end

      context 'when the like does not belong to the logged-in user' do
        let!(:post_like2) { create(:like, :likeable_type_post) }

        it 'does not delete the like' do
          expect do
            delete like_path(id: post_like2.id), xhr: true
          end.to change(Like, :count).by(0)
        end

        it 'creates an alert' do
          delete like_path(id: post_like2.id)
          expect(flash[:alert]).to eq('Record not found.')
        end

        it 'redirects to root path' do
          delete like_path(id: post_like2.id)
          expect(response).to redirect_to(root_path)
        end
      end

      context 'when the like does not exist' do
        it 'does not delete any like' do
          expect do
            delete like_path(id: 0), xhr: true
          end.to change(Like, :count).by(0)
        end
      end
    end
  end
end
