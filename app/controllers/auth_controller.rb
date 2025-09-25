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
