# frozen_string_literal: true

json.replies comment.comments do |reply|
  json.extract! reply, :id, :content
  json.partial! 'replies', comment: reply
end
