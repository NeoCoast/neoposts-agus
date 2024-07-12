# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    include DeviseTokenAuth::Concerns::SetUserByToken
    before_action :authenticate_user!, unless: :devise_controller?
  end
end
