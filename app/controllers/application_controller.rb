class ApplicationController < ActionController::Base
  # Include debugging helper
  include SessionDebug
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Auth cookie name and settings
  AUTH_COOKIE_NAME = "booking_auth_token"
  AUTH_COOKIE_EXPIRY = 2.weeks
  
  # Make authentication helper available to views
  helper_method :authenticated?
  
  before_action :require_authentication
  before_action :set_locale
  
  # Skip authentication for locale switching and login
  skip_before_action :require_authentication, only: [:change_locale, :set_locale_api]
  
  # Form-based locale switcher that preserves authentication state
  def change_locale
    log_session_info("BEFORE change_locale")
    
    # Store current authentication state before changing locale
    was_authenticated = authenticated?
    
    # Change locale if valid
    if valid_locale?(params[:new_locale])
      session[:locale] = params[:new_locale]
      I18n.locale = params[:new_locale]
    end
    
    # Determine redirect location based on stored auth state
    if was_authenticated
      redirect_path = params[:return_to].present? ? params[:return_to] : root_path
    else
      redirect_path = login_path
    end
    
    log_session_info("AFTER change_locale - authenticated: #{was_authenticated}, redirecting to: #{redirect_path}")
    
    # Redirect back to the original URL
    redirect_to redirect_path
  end
  
  # API-based locale switcher that preserves authentication state
  def set_locale_api
    log_session_info("API set_locale_api - BEFORE")
    
    # Parse the request body if it's JSON
    locale_param = params[:locale]
    
    # Change locale if valid
    if valid_locale?(locale_param)
      session[:locale] = locale_param
      I18n.locale = locale_param
      log_session_info("API set_locale_api - locale set to #{locale_param}")
      render json: { success: true, locale: locale_param }
    else
      log_session_info("API set_locale_api - invalid locale: #{locale_param}")
      render json: { success: false, error: "Invalid locale" }, status: :bad_request
    end
  end
  
  private
  
  # Set authentication cookie and session
  def set_authenticated(value)
    if value
      # Generate a secure random token
      auth_token = SecureRandom.hex(32)
      
      # Store in both session and cookie for redundancy
      session[:authenticated] = true
      
      # Set a persistent cookie that will survive across requests
      cookies.signed[AUTH_COOKIE_NAME] = {
        value: auth_token,
        expires: AUTH_COOKIE_EXPIRY.from_now,
        httponly: true,
        secure: Rails.env.production?
      }
      
      # Preserve the access_key_id if it's in the session
      # This will be set separately in the auth controller
      
      log_session_info("SETTING AUTHENTICATION - Token created")
    else
      # Clear both session and cookie
      session[:authenticated] = nil
      session[:access_key_id] = nil  # Also clear the access key ID
      cookies.delete(AUTH_COOKIE_NAME)
      cookies.delete("access_key_id")
      
      log_session_info("CLEARING AUTHENTICATION")
    end
  end
  
  # Check if user is authenticated using both session and cookie
  def authenticated?
    session_auth = !!session[:authenticated]
    cookie_auth = cookies.signed[AUTH_COOKIE_NAME].present?
    
    # Don't log here to avoid infinite recursion with log_session_info
    session_auth || cookie_auth
  end
  
  def valid_locale?(locale)
    locale.present? && I18n.available_locales.include?(locale.to_sym)
  rescue
    false
  end
  
  def require_authentication
    log_session_info("IN require_authentication")
    unless authenticated?
      redirect_to login_path
    end
  end
  
  def set_locale
    # Check session first, then default to English
    if session[:locale].present? && I18n.available_locales.include?(session[:locale].to_sym)
      I18n.locale = session[:locale]
    else
      I18n.locale = I18n.default_locale
    end
  end
end
