class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    #   # For additional fields in app/views/devise/registrations/new.html.erb
    #   devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    # devise_parameter_sanitizer.permit(:sign_up, keys: %i[name contact_number address postcode]

    #   # For additional in app/views/devise/registrations/edit.html.erb
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name contact_number address postcode])
  end
end
