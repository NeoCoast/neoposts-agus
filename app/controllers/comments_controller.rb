# frozen_string_literal: true

class CommentsController < ApplicationController
  def create
    @commentable = params[:commentable_type].constantize.find(params[:commentable_id])
    @comment = @commentable.comments.build(content: params[:comment][:content], user_id: current_user.id)

    if @comment.save
      respond_to_format
    else
      respond_to_format_with_error
    end
  end

  private

  def respond_to_format
    respond_to do |format|
      format.html { redirect_to request.referer || root_path, notice: 'Comment was successfully created.' }
      format.js
    end
  end

  def respond_to_format_with_error
    respond_to do |format|
      format.html { redirect_to (request.referer || root_path), alert: 'There was an error creating the comment.' }
      format.js
    end
  end
end
