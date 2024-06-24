# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  describe 'POST /create' do
    let(:new_user) { create(:user) }
    let(:new_post) { create(:post) }

    context 'when the user is not logged in' do
      let(:params) do
        { user_id: new_user.id, commentable_type: new_post.class.name, commentable_id: new_post.id,
          comment: attributes_for(:comment, :with_content) }
      end

      context 'when the request format is HTML' do
        before { post comments_path, params: }

        it { should redirect_to(new_user_session_path) }
      end

      context 'when the request format is JavaScript' do
        before { post comments_path, params:, xhr: true }

        it 'returns 401 Unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when the user is logged in' do
      before { sign_in new_user }

      context 'when the request format is HTML' do
        context 'when it is a comment on a post' do
          context 'when comment has content attribute' do
            let(:params) do
              { user_id: new_user.id, commentable_type: new_post.class.name, commentable_id: new_post.id,
                comment: attributes_for(:comment, :with_content) }
            end

            it 'creates a comment' do
              expect do
                post comments_path, params:
              end.to change(Comment, :count).by(1)
            end

            it 'creates a notice indicating that the comment was successfully created' do
              post(comments_path, params:)
              expect(flash[:notice]).to eq('Comment was successfully created.')
            end

            it 'returns an HTML response' do
              post(comments_path, params:)
              expect(response.content_type).to eq 'text/html; charset=utf-8'
            end
          end

          context 'when comment has no content attribute' do
            let(:params) do
              { user_id: new_user.id, commentable_type: new_post.class.name, commentable_id: new_post.id,
                comment: attributes_for(:comment, :without_content) }
            end

            it 'does not create a comment' do
              expect do
                post comments_path, params:
              end.to change(Comment, :count).by(0)
            end

            it 'creates an alert' do
              post(comments_path, params:)
              expect(flash[:alert]).to eq('There was an error creating the comment.')
            end
          end
        end

        context 'when it is a comment on a comment' do
          let!(:new_comment) { create(:comment_of_post) }

          context 'when comment has content attribute' do
            let(:params) do
              { user_id: new_user.id, commentable_type: new_comment.class.name, commentable_id: new_comment.id,
                comment: attributes_for(:comment, :with_content) }
            end

            it 'creates a comment' do
              expect do
                post comments_path, params:
              end.to change(Comment, :count).by(1)
            end

            it 'creates a notice indicating that the comment was successfully created' do
              post(comments_path, params:)
              expect(flash[:notice]).to eq('Comment was successfully created.')
            end

            it 'returns an HTML response' do
              post(comments_path, params:)
              expect(response.content_type).to eq 'text/html; charset=utf-8'
            end
          end

          context 'when comment has no content attribute' do
            let(:params) do
              { user_id: new_user.id, commentable_type: new_comment.class.name, commentable_id: new_comment.id,
                comment: attributes_for(:comment, :without_content) }
            end

            it 'does not create a comment' do
              expect do
                post comments_path, params:
              end.to change(Comment, :count).by(0)
            end

            it 'creates an alert' do
              post(comments_path, params:)
              expect(flash[:alert]).to eq('There was an error creating the comment.')
            end
          end
        end
      end

      context 'when the request format is JavaScript' do
        context 'when it is a comment on a post' do
          context 'when comment has content attribute' do
            let(:comment_attributes) { attributes_for(:comment, :with_content) }

            context 'when a valid commentable is provided' do
              let(:params) do
                { user_id: new_user.id, commentable_type: new_post.class.name, commentable_id: new_post.id,
                  comment: comment_attributes }
              end

              it 'creates a comment' do
                expect do
                  post comments_path, params:, xhr: true
                end.to change(Comment, :count).by(1)
              end

              it 'responds with success' do
                post comments_path, params:, xhr: true
                expect(response).to have_http_status(:success)
              end

              it 'renders the new comment' do
                post comments_path, params:, xhr: true
                expect(response.body).to include(CGI.escapeHTML(comment_attributes[:content]))
              end

              it 'returns a JavaScript response' do
                post comments_path, params:, xhr: true
                expect(response.content_type).to eq('text/javascript; charset=utf-8')
              end
            end

            context 'when no valid commentable is provided' do
              let(:params) do
                { user_id: new_user.id, commentable_type: new_post.class.name, commentable_id: '',
                  comment: comment_attributes }
              end

              it 'does not create the comment' do
                expect do
                  post comments_path, params:, xhr: true
                end.to change(Comment, :count).by(0)
              end
            end
          end

          context 'when comment has no content attribute' do
            let(:params) do
              { user_id: new_user.id, commentable_type: new_post.class.name, commentable_id: new_post.id,
                comment: attributes_for(:comment, :without_content) }
            end

            it 'does not create a comment' do
              expect do
                post comments_path, params:, xhr: true
              end.to change(Comment, :count).by(0)
            end
          end
        end
      end

      context 'when it is a comment on a comment' do
        let!(:new_comment) { create(:comment_of_post) }

        context 'when comment has content attribute' do
          let(:comment_attributes) { attributes_for(:comment, :with_content) }

          context 'when a valid commentable is provided' do
            let(:params) do
              { user_id: new_user.id, commentable_type: new_comment.class.name, commentable_id: new_comment.id,
                comment: comment_attributes }
            end

            it 'creates a comment' do
              expect do
                post comments_path, params:, xhr: true
              end.to change(Comment, :count).by(1)
            end

            it 'responds with success' do
              post comments_path, params:, xhr: true
              expect(response).to have_http_status(:success)
            end

            it 'renders the new comment' do
              post comments_path, params:, xhr: true
              expect(response.body).to include(CGI.escapeHTML(comment_attributes[:content]))
            end

            it 'returns a JavaScript response' do
              post comments_path, params:, xhr: true
              expect(response.content_type).to eq('text/javascript; charset=utf-8')
            end
          end

          context 'when no valid commentable is provided' do
            let(:params) do
              { user_id: new_user.id, commentable_type: new_comment.class.name, commentable_id: '',
                comment: comment_attributes }
            end

            it 'does not create the comment' do
              expect do
                post comments_path, params:, xhr: true
              end.to change(Comment, :count).by(0)
            end
          end
        end

        context 'when comment has no content attribute' do
          let(:params) do
            { user_id: new_user.id, commentable_type: new_comment.class.name, commentable_id: new_comment.id,
              comment: attributes_for(:comment, :without_content) }
          end
          it 'does not create a comment' do
            expect do
              post comments_path, params:, xhr: true
            end.to change(Comment, :count).by(0)
          end
        end
      end
    end
  end
end
