class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :set_locale
  
  def switch_locale
    if params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
      session[:locale] = params[:locale]
      I18n.locale = params[:locale]
    end
    redirect_to root_path
  end
  
  def reset_locale
    session[:locale] = nil
    I18n.locale = I18n.default_locale
    redirect_to root_path
  end
  
  private
  
  def set_locale
    # Check URL parameter first, then session, then default to English
    if params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    elsif session[:locale].present? && I18n.available_locales.include?(session[:locale].to_sym)
      I18n.locale = session[:locale]
    else
      I18n.locale = I18n.default_locale
    end
  end
end
