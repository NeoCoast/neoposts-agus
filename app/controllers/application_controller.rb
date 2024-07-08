# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :devise_controller?
  protect_from_forgery with: :exception, if: proc { |controller| controller.request.format != 'application/json' }
  protect_from_forgery with: :null_session, if: proc { |controller| controller.request.format == 'application/json' }

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[nickname first_name last_name birthday profile_picture])
  end

  def record_not_found
    redirect_to root_path, alert: 'Record not found.'
  end
end
