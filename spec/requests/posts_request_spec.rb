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

      before { sign_in new_user }

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
      let(:new_follow_relationship) { create(:follow_relationship) }
      before { sign_in new_follow_relationship.follower }

      context 'when no sorting criteria is set' do
        let!(:followed_post_a) { create(:post, user: new_follow_relationship.followed, published_at: 1.day.ago) }
        let!(:followed_post_b) { create(:post, user: new_follow_relationship.followed, published_at: 1.week.ago) }
        let!(:unfollowed_post) { create(:post) }
        before { get posts_path }

        it 'renders a successful response' do
          expect(response).to be_successful
        end

        it 'should display the posts of the followed users' do
          expect(response.body).to include(CGI.escapeHTML(followed_post_a.user.nickname))
        end

        it 'should not display the posts of the unfollowed users' do
          expect(response.body).not_to include(CGI.escapeHTML(unfollowed_post.user.nickname))
        end

        it 'includes the first post of followed user' do
          expect(response.body).to include(CGI.escapeHTML(followed_post_a.title))
        end

        it 'includes the second post of followed user' do
          expect(response.body).to include(CGI.escapeHTML(followed_post_b.title))
        end

        it 'returns posts ordered by newest' do
          posts = controller.instance_variable_get('@posts')
          expect(posts.first.title).to eq(followed_post_a.title) # newest first
          expect(posts.second.title).to eq(followed_post_b.title)
        end
      end

      context 'when sorting by number of likes' do
        let!(:post_a) { create(:post, user: new_follow_relationship.followed, likes_count: 0) }
        let!(:post_b) { create(:post, user: new_follow_relationship.followed, likes_count: 1) }
        before { get posts_path, params: { sort_criteria: 'number_of_likes' }, xhr: true }

        it 'returns posts ordered by number of likes' do
          posts = controller.instance_variable_get('@posts')
          expect(posts.first.title).to eq(post_b.title) # most liked first
          expect(posts.second.title).to eq(post_a.title)
        end
      end

      context 'when sorting by trending value' do
        context 'when one post has more days since creation than the other' do
          let!(:post_a) do
            create(:post, user: new_follow_relationship.followed, likes_count: 10, created_at: 20.days.ago)
          end
          # more trendy post
          let!(:post_b) do
            create(:post, user: new_follow_relationship.followed, likes_count: 10, created_at: 10.days.ago)
          end
          before { get posts_path, params: { sort_criteria: 'trending' }, xhr: true }

          it 'returns posts ordered by trending value' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.first.title).to eq(post_b.title) # most trending first
            expect(posts.second.title).to eq(post_a.title)
          end
        end

        context 'when one post has more likes than the other' do
          # more trendy post
          let!(:post_a) do
            create(:post, user: new_follow_relationship.followed, likes_count: 20, created_at: 10.days.ago)
          end
          let!(:post_b) do
            create(:post, user: new_follow_relationship.followed, likes_count: 10, created_at: 10.days.ago)
          end
          before { get posts_path, params: { sort_criteria: 'trending' }, xhr: true }

          it 'returns posts ordered by trending value' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.first.title).to eq(post_a.title) # most trending first
            expect(posts.second.title).to eq(post_b.title)
          end
        end
      end

      context 'when filtering by date' do
        let!(:post_a) { create(:post, user: new_follow_relationship.followed, published_at: 1.day.ago) }
        let!(:post_b) { create(:post, user: new_follow_relationship.followed, published_at: 1.week.ago) }
        let!(:post_c) { create(:post, user: new_follow_relationship.followed, published_at: 1.month.ago) }

        context 'when filtering by last day' do
          before { get posts_path, params: { filter_by_date_criteria: 1.day.ago }, xhr: true }

          it 'returns posts published on the last day' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.first.title).to eq(post_a.title)
          end

          it 'does not return posts published before the last day' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.length).to eq(1)
          end
        end

        context 'when filtering by last week' do
          before { get posts_path, params: { filter_by_date_criteria: 1.week.ago }, xhr: true }

          it 'returns posts published on the last week' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.second.title).to eq(post_b.title)
          end

          it 'returns posts published on the last day' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.first.title).to eq(post_a.title)
          end

          it 'does not return posts published before the last week' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.length).to eq(2)
          end
        end

        context 'when filtering by last month' do
          before { get posts_path, params: { filter_by_date_criteria: 1.month.ago }, xhr: true }

          it 'returns posts published on the last month' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.third.title).to eq(post_c.title)
          end

          it 'returns posts published on the last week' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.second.title).to eq(post_b.title)
          end

          it 'returns posts published on the last day' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.first.title).to eq(post_a.title)
          end
        end
      end

      context 'when filtering by text' do
        let!(:post_a) do
          create(:post, user: new_follow_relationship.followed, published_at: 1.day.ago, title: 'Title Post a',
                        body: 'Body Post a')
        end
        let!(:post_b) do
          create(:post, user: new_follow_relationship.followed, published_at: 1.week.ago, title: 'Title Post b',
                        body: 'Body Post b')
        end
        let!(:post_c) do
          create(:post, user: new_follow_relationship.followed, published_at: 1.month.ago, title: 'Title Post c',
                        body: 'Body Post c')
        end

        context "when the text is included in author's first_name" do
          before { get posts_path, params: { filter_by_text_criteria: post_a.user.first_name[1..-2] }, xhr: true }

          it 'returns posts which include the text' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.first.title).to eq(post_a.title)
          end
        end

        context "when the text is included in author's last_name" do
          before { get posts_path, params: { filter_by_text_criteria: post_a.user.last_name[1..-2] }, xhr: true }

          it 'returns posts which include the text' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.first.title).to eq(post_a.title)
          end
        end

        context "when the text is included in author's nickname" do
          before { get posts_path, params: { filter_by_text_criteria: post_a.user.nickname[1..-2] }, xhr: true }

          it 'returns posts which include the text' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.first.title).to eq(post_a.title)
          end
        end

        context 'when the text is included in the title of a post' do
          before { get posts_path, params: { filter_by_text_criteria: 'Title Post b' }, xhr: true }

          it 'returns posts which include the text' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.first.title).to eq(post_b.title)
          end

          it "does not return posts which don't include the text" do
            posts = controller.instance_variable_get('@posts')
            expect(posts.length).to eq(1)
          end
        end

        context 'when the text is included in the body of a post' do
          before { get posts_path, params: { filter_by_text_criteria: 'Body Post c' }, xhr: true }

          it 'returns posts which include the text' do
            posts = controller.instance_variable_get('@posts')
            expect(posts.first.title).to eq(post_c.title)
          end

          it "does not return posts which don't include the text" do
            posts = controller.instance_variable_get('@posts')
            expect(posts.length).to eq(1)
          end
        end
      end

      context 'when filtering by date, filtering by text and sorting at the same time' do
        let!(:post_a) do
          create(:post, user: new_follow_relationship.followed, published_at: 1.day.ago, likes_count: 0, title: 'Title')
        end
        let!(:post_b) do
          create(:post, user: new_follow_relationship.followed, published_at: 1.week.ago, likes_count: 1,
                        title: 'Title')
        end
        let!(:post_c) do
          create(:post, user: new_follow_relationship.followed, published_at: 1.month.ago, likes_count: 2)
        end

        before do
          get posts_path,
              params: { filter_by_date_criteria: 1.week.ago,
                        filter_by_text_criteria: 'Title',
                        sort_criteria: 'number_of_likes' }, xhr: true
        end

        it 'returns posts published on the last week' do
          posts = controller.instance_variable_get('@posts')
          expect(posts.first.title).to eq(post_b.title)
          expect(posts.second.title).to eq(post_a.title)
        end

        it 'does not return posts published before the last week' do
          posts = controller.instance_variable_get('@posts')
          expect(posts.length).to eq(2)
        end

        it 'returns posts which include the text' do
          posts = controller.instance_variable_get('@posts')
          expect(posts.first.title).to eq(post_b.title)
          expect(posts.second.title).to eq(post_a.title)
        end

        it 'returns posts ordered by number of likes' do
          posts = controller.instance_variable_get('@posts')
          expect(posts.first.title).to eq(post_b.title) # most liked first
          expect(posts.second.title).to eq(post_a.title)
        end
      end
    end
  end

  describe 'DELETE /destroy' do
    let!(:new_post) { create(:post) }

    context 'when the user is not logged in' do
      before { delete post_path(new_post.id) }

      it { should redirect_to(new_user_session_path) }
    end

    context 'when the user is logged in' do
      let(:new_user) { create(:user) }
      let!(:logged_user_post) { create(:post, user: new_user) }

      before { sign_in new_user }

      context 'when the post belongs to the logged in user' do
        it 'deletes the post' do
          expect do
            delete post_path(logged_user_post.id)
          end.to change(Post, :count).by(-1)
        end

        it 'redirects to root path' do
          delete post_path(logged_user_post.id)
          expect(response).to redirect_to(root_path)
        end
      end

      context 'when the post does not belong to the logged in user' do
        it 'does not delete the post' do
          expect do
            delete post_path(new_post.id)
          end.to change(Post, :count).by(0)
        end

        it 'redirects to root path' do
          delete post_path(new_post.id)
          expect(response).to redirect_to(root_path)
        end
      end

      context 'when deleting a non existent post' do
        it 'does not delete the post' do
          expect do
            delete post_path(0)
          end.to change(Post, :count).by(0)
        end

        it 'redirects to root path' do
          delete post_path(0)
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
