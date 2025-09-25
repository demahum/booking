module SessionDebug
  extend ActiveSupport::Concern
  
  included do
    def log_session_info(action_name)
      Rails.logger.info "\n\n===== SESSION DEBUG: #{action_name} =====\n"
      Rails.logger.info "  session[:authenticated] = #{session[:authenticated].inspect} (class: #{session[:authenticated].class})\n"
      Rails.logger.info "  auth_cookie = #{cookies.signed[ApplicationController::AUTH_COOKIE_NAME].present? ? 'PRESENT' : 'NOT PRESENT'}\n"
      # Remove the call to authenticated? which was causing infinite recursion
      Rails.logger.info "  session[:locale] = #{session[:locale].inspect}\n"
      Rails.logger.info "  request.referer = #{request.referer.inspect}\n"
      Rails.logger.info "  request.path = #{request.path.inspect}\n"
      Rails.logger.info "  params = #{params.except(:authenticity_token).inspect}\n"
      Rails.logger.info "  session object_id = #{session.object_id}\n" 
      Rails.logger.info "  request.cookies = #{request.cookies.keys.join(', ')}\n"
      Rails.logger.info "================================================\n\n"
    end
  end
end