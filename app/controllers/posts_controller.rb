# frozen_string_literal: true

class PostsController < ApplicationController
  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.new(post_params)

    if @post.save
      redirect_to @post
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @post = Post.find_by_id(params[:id])
    redirect_to root_path, alert: 'Post not found' unless @post
  end

  def index
    @posts = current_user.followed_posts.ordered_by_newest
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :image)
  end
end
