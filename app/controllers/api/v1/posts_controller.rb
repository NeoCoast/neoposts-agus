# frozen_string_literal: true

module Api
  module V1
    class PostsController < BaseController
      def index
        user = User.find(params[:user_id])
        @posts = user.posts
      end

      def show
        @post = Post.find(params[:id])
      end

      def create
        user = User.find(params[:user_id])
        if user.id == current_user.id
          @post = current_user.posts.create!(post_params)
        else
          render json: { errors: ['You can only create a post for yourself.'] }, status: :forbidden
        end
      end

      private

      def post_params
        params.permit(:title, :body)
      end
    end
  end
end
