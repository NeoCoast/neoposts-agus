# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :verify_current_user, :find_user, only: %i[edit update]

  def show
    @user = User.find_by(nickname: params[:nickname])
    return redirect_to root_path, alert: 'User not found' unless @user

    @posts = @user.posts.ordered_by_newest
  end

  def edit; end

  def update
    if @user.update_with_password(user_params)
      bypass_sign_in @user
      redirect_to user_profile_path(@user.nickname)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def find_user
    @user = User.find_by(id: params[:id])
  end

  def verify_current_user
    redirect_to root_path, alert: "You can't edit other user's profiles" unless current_user.id == params[:id].to_i
  end

  def user_params
    params.require(:user).permit(:email, :nickname, :first_name, :last_name, :birthday, :profile_picture,
                                 :current_password, :password, :password_confirmation)
  end
end
