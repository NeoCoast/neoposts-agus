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
    @post = Post.find(params[:id])
  end

  def index
    @posts = Post.ordered_by_newest
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :image)
  end
end
