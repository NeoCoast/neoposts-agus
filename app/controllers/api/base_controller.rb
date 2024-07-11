# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    include DeviseTokenAuth::Concerns::SetUserByToken
    before_action :authenticate_user!, unless: :devise_controller?

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    def record_not_found(exception)
      resource = exception.model || 'Resource'
      render json: { error: "#{resource} not found." }, status: :not_found
    end
  end
end
