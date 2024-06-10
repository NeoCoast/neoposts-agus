# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FollowRelationships', type: :request do
  describe 'POST /create' do
    let(:follower_user) { create(:user) }
    let(:followed_user) { create(:user) }

    context 'when the user is not logged in' do
      context 'when the request format is HTML' do
        before { post follow_relationships_path, params: { followed_id: followed_user.id } }

        it { should redirect_to(new_user_session_path) }
      end

      context 'when the request format is JavaScript' do
        before { post follow_relationships_path, params: { followed_id: followed_user.id }, xhr: true }

        it 'returns 401 Unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when the user is logged in' do
      before { sign_in follower_user }

      context 'when the request format is HTML' do
        it 'creates a follow relationship' do
          expect do
            post follow_relationships_path, params: { followed_id: followed_user.id }
          end.to change(FollowRelationship, :count).by(1)
        end

        it 'creates a following for the follower user' do
          expect do
            post follow_relationships_path, params: { followed_id: followed_user.id }
          end.to change { follower_user.following.count }.by(1)
        end

        it 'creates a follower for the followed user' do
          expect do
            post follow_relationships_path, params: { followed_id: followed_user.id }
          end.to change { followed_user.followers.count }.by(1)
        end

        it 'returns 302 Found' do
          post follow_relationships_path, params: { followed_id: followed_user.id }
          expect(response).to have_http_status(:found)
        end

        it 'redirects to the followed user profile' do
          post follow_relationships_path, params: { followed_id: followed_user.id }
          should redirect_to(user_profile_path(followed_user.nickname))
        end

        it 'returns an HTML response' do
          post follow_relationships_path, params: { followed_id: followed_user.id }
          expect(response.content_type).to eq 'text/html; charset=utf-8'
        end
      end

      context 'when the request format is JavaScript' do
        it 'creates a follow relationship' do
          expect do
            post follow_relationships_path, params: { followed_id: followed_user.id }, xhr: true
          end.to change(FollowRelationship, :count).by(1)
        end

        it 'creates a following for the follower user' do
          expect do
            post follow_relationships_path, params: { followed_id: followed_user.id }, xhr: true
          end.to change { follower_user.following.count }.by(1)
        end

        it 'creates a follower for the followed user' do
          expect do
            post follow_relationships_path, params: { followed_id: followed_user.id }, xhr: true
          end.to change { followed_user.followers.count }.by(1)
        end

        it 'responds with success' do
          post follow_relationships_path, params: { followed_id: followed_user.id }, xhr: true
          expect(response).to have_http_status(:success)
        end

        it 'returns a JavaScript response' do
          post follow_relationships_path, params: { followed_id: followed_user.id }, xhr: true
          expect(response.content_type).to eq('text/javascript; charset=utf-8')
        end

        it 'changes the follow button to the unfollow button' do
          post follow_relationships_path, params: { followed_id: followed_user.id }, xhr: true
          expect(response.body).to include('Unfollow')
        end
      end

      context 'when following an already followed user' do
        before { create(:follow_relationship, follower: follower_user, followed: followed_user) }

        it 'does not create any follow relationship' do
          expect do
            post follow_relationships_path, params: { followed_id: followed_user.id }, xhr: true
          end.to change(FollowRelationship, :count).by(0)
        end

        it 'changes the follow button to the unfollow button' do
          post follow_relationships_path, params: { followed_id: followed_user.id }, xhr: true
          expect(response.body).to include('Unfollow')
        end
      end
    end
  end

  describe 'DELETE /destroy' do
    context 'when the user is not logged in' do
      let!(:new_follow_relationship) { create(:follow_relationship) }

      context 'when the request format is HTML' do
        before { delete follow_relationship_path(id: new_follow_relationship.id) }

        it { should redirect_to(new_user_session_path) }
      end

      context 'when the request format is JavaScript' do
        before { delete follow_relationship_path(id: new_follow_relationship.id), xhr: true }

        it 'returns 401 Unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when the user is logged in' do
      let(:new_user) { create(:user) }
      before { sign_in new_user }

      context 'when the request format is HTML' do
        let!(:new_follow_relationship) { create(:follow_relationship, follower: new_user) }

        it 'deletes a follow relationship' do
          expect do
            delete follow_relationship_path(id: new_follow_relationship.id)
          end.to change(FollowRelationship, :count).by(-1)
        end

        it 'deletes the following for the follower user' do
          expect do
            delete follow_relationship_path(id: new_follow_relationship.id)
          end.to change { new_follow_relationship.follower.following.count }.by(-1)
        end

        it 'deletes the follower for the followed user' do
          expect do
            delete follow_relationship_path(id: new_follow_relationship.id)
          end.to change { new_follow_relationship.followed.followers.count }.by(-1)
        end

        it 'returns 302 Found' do
          delete follow_relationship_path(id: new_follow_relationship.id)
          expect(response).to have_http_status(:found)
        end

        it 'redirects to the followed user profile' do
          delete follow_relationship_path(id: new_follow_relationship.id)
          should redirect_to(user_profile_path(new_follow_relationship.followed.nickname))
        end

        it 'returns an HTML response' do
          delete follow_relationship_path(id: new_follow_relationship.id)
          expect(response.content_type).to eq 'text/html; charset=utf-8'
        end
      end

      context 'when the request format is JavaScript' do
        let!(:new_follow_relationship) { create(:follow_relationship, follower: new_user) }

        it 'deletes a follow relationship' do
          expect do
            delete follow_relationship_path(id: new_follow_relationship.id), xhr: true
          end.to change(FollowRelationship, :count).by(-1)
        end

        it 'deletes the following for the follower user' do
          expect do
            delete follow_relationship_path(id: new_follow_relationship.id), xhr: true
          end.to change { new_follow_relationship.follower.following.count }.by(-1)
        end

        it 'deletes the follower for the followed user' do
          expect do
            delete follow_relationship_path(id: new_follow_relationship.id), xhr: true
          end.to change { new_follow_relationship.followed.followers.count }.by(-1)
        end

        it 'responds with success' do
          delete follow_relationship_path(id: new_follow_relationship.id), xhr: true
          expect(response).to have_http_status(:success)
        end

        it 'returns a JavaScript response' do
          delete follow_relationship_path(id: new_follow_relationship.id), xhr: true
          expect(response.content_type).to eq('text/javascript; charset=utf-8')
        end

        it 'changes the unfollow button to the follow button' do
          delete follow_relationship_path(id: new_follow_relationship.id), xhr: true
          expect(response.body).to include('Follow')
        end
      end

      context 'when unfollowing a not followed user' do
        it 'does not delete any follow relationship' do
          expect do
            delete follow_relationship_path(id: 0), xhr: true
          end.to change(FollowRelationship, :count).by(0)
        end
      end
    end
  end
end
