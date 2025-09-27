class AuthController < ApplicationController
  skip_before_action :require_authentication, only: [:login, :authenticate], if: :method_defined?
  layout "auth"
  
  def login
    # Show login form
    redirect_to root_path if authenticated?
  end

  def authenticate
    log_session_info("BEFORE authenticate")
    
    key = params[:access_key]
    valid_key = AccessKey.find_by(key: key, active: true)

    if valid_key
      # Set authentication using our robust method
      set_authenticated(true)
      
      # Store the access key ID in the session
      session[:access_key_id] = valid_key.id
      
      # Also store in a separate cookie for redundancy
      cookies.signed[:access_key_id] = {
        value: valid_key.id,
        expires: ApplicationController::AUTH_COOKIE_EXPIRY.from_now,
        httponly: true,
        secure: Rails.env.production?
      }
      
      # Log the access key ID to help debug
      Rails.logger.info "=== STORING ACCESS KEY ID IN SESSION: #{valid_key.id} ==="
      Rails.logger.info "=== SESSION ACCESS_KEY_ID: #{session[:access_key_id].inspect} ==="
      Rails.logger.info "=== ENTIRE SESSION: #{session.to_h.inspect} ==="
      Rails.logger.info "=== ALSO STORING IN COOKIE: access_key_id=#{valid_key.id} ==="
      
      log_session_info("AFTER successful authenticate")
      redirect_to root_path, notice: t('auth.login_success')
    else
      # Failed authentication
      flash.now[:alert] = t('auth.invalid_key')
      log_session_info("AFTER failed authenticate")
      render :login, status: :unprocessable_entity
    end
  end

  def logout
    log_session_info("BEFORE logout")
    set_authenticated(false)
    log_session_info("AFTER logout")
    redirect_to login_path, notice: t('auth.logout_success')
  end
  
  private
  
  # Check if the method is defined to avoid errors if require_authentication isn't defined yet
  def method_defined?
    self.class.superclass.instance_methods.include?(:require_authentication)
  end
end
