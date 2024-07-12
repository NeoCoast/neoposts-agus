# frozen_string_literal: true

module Api
  module V1
    class PostsController < BaseController
      def index
        user = User.find(params[:user_id])
        @posts = user.posts
      end
    end
  end
end
