# frozen_string_literal: true

json.array! @posts do |post|
  json.partial! 'post', post:
end
