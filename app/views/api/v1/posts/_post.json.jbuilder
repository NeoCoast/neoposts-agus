# frozen_string_literal: true

json.call(post, :id, :title, :body, :published_at, :user_id, :likes_count)
json.comments_count post.comments.size
