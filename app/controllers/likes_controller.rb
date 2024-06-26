# frozen_string_literal: true

class LikesController < ApplicationController
  def create
    @likeable = params[:likeable_type].constantize.find(params[:likeable_id])
    @likeable.likes.create!(user_id: current_user.id)
    respond_to_format
  end

  def destroy
    like = current_user.likes.find(params[:id])
    @likeable = like&.likeable_type&.constantize&.find(like.likeable_id)
    like&.destroy
    respond_to_format
  end

  private

  def respond_to_format
    respond_to do |format|
      format.html { redirect_to request.referer || root_path }
      format.js
    end
  end
end
