class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  def store_user_location!
    # store location if user is not signed in
    return if user_signed_in?

    # Only store location for full page loads, not XHR or partial requests
    if request.get? &&
       request.method == 'GET' &&
       !request.xhr? &&
       request.format.html? &&
       !request.headers['X-Requested-With']&.include?('Fetch')
      session[:user_previous_location] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    # prioritize session location, then Devise's stored location
    previous_location = session.delete(:user_previous_location)
    stored_location = previous_location || stored_location_for(resource)

    stored_location.present? ? stored_location : root_path
  end

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
