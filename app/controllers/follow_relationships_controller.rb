# frozen_string_literal: true

class FollowRelationshipsController < ApplicationController
  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to_format(@user.nickname)
  end

  def destroy
    @user = FollowRelationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to_format(@user.nickname)
  end

  private

  def respond_to_format(nickname)
    respond_to do |format|
      format.html { redirect_to user_profile_path(nickname) }
      format.js
    end
  end
end
