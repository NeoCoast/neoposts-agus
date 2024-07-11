# frozen_string_literal: true

json.array! @posts do |post|
  json.extract! post, :id, :title, :body, :published_at, :user_id, :likes_count
  json.comments_count post.comments.size
end
