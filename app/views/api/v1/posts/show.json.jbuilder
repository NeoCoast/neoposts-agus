# frozen_string_literal: true

json.call(@post, :id, :title, :body, :published_at, :user_id)

json.likes @post.likes do |like|
  json.user_id like.user_id
  json.nickname like.user.nickname
end

json.comments @post.comments do |comment|
  json.extract! comment, :id, :content
  json.partial! 'replies', comment:
end
