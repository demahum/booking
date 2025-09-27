class HomeController < ApplicationController
  def index
    # Authentication is now handled by the parent class using cookies
    # We don't need to manually set auth state from parameters anymore
    
    # Handle current month/year for calendar display
    # Only use params if both month and year are present, otherwise default to current date
    if params[:month].present? && params[:year].present?
      @current_month = Date.parse("#{params[:year]}-#{params[:month]}-01")
      @current_month = @current_month.beginning_of_month
    else
      @current_month = Date.current.beginning_of_month
    end
    
    # Handle date range selection
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : nil
    @end_date = params[:end_date] ? Date.parse(params[:end_date]) : nil
    
    # Ensure start_date is before end_date
    if @start_date && @end_date && @start_date > @end_date
      @start_date, @end_date = @end_date, @start_date
    end
    
    # Load existing bookings to show as unavailable
    @booked_dates = Set.new
    DateRange.all.each do |booking|
      (booking.start_date..booking.end_date).each do |date|
        @booked_dates.add(date)
      end
    end
    
    # Check if the selected range conflicts with existing bookings
    if @start_date && @end_date && range_conflicts_with_bookings?(@start_date, @end_date, @booked_dates)
      # Reset the conflicting selection
      @start_date = params[:start_date] ? Date.parse(params[:start_date]) : nil
      @end_date = nil
    end
    
    # Create date range for easier checking
    @selected_range = if @start_date && @end_date
                       (@start_date..@end_date)
                     elsif @start_date
                       (@start_date..@start_date)
                     else
                       nil
                     end
  rescue ArgumentError
    @current_month = Date.current.beginning_of_month
    @start_date = nil
    @end_date = nil
    @selected_range = nil
  end

  def save_range
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : nil
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : nil
    
    # Ensure we have both dates
    unless start_date && end_date
      redirect_to root_path(locale: params[:locale]), alert: t('messages.select_complete_range')
      return
    end
    
    # Ensure start_date is before end_date
    if start_date > end_date
      start_date, end_date = end_date, start_date
    end
    
    # Get the current access key - try multiple methods
    current_access_key = get_current_access_key
    
    # Create the date range record with the associated access key
    date_range = DateRange.new(
      start_date: start_date, 
      end_date: end_date,
      access_key: current_access_key
    )
    
    # Log what we're saving
    Rails.logger.info "=== SAVING DATE RANGE ==="
    Rails.logger.info "=== START DATE: #{start_date.inspect} ==="
    Rails.logger.info "=== END DATE: #{end_date.inspect} ==="
    Rails.logger.info "=== WITH ACCESS KEY: #{current_access_key.inspect} ==="
    
    # Preserve the locale for redirects
    locale_param = { locale: params[:locale] } if params[:locale].present?
    
    if date_range.save
      # Send email notification about new reservation
      begin
        NotificationMailer.reservation_created(date_range, current_access_key).deliver_later
        Rails.logger.info "=== EMAIL NOTIFICATION QUEUED FOR DATE RANGE #{date_range.id} ==="
      rescue => e
        # Log the error but don't fail the booking process
        Rails.logger.error "=== ERROR SENDING EMAIL NOTIFICATION: #{e.message} ==="
      end
      
      redirect_to root_path(locale_param), notice: t('messages.range_saved_success')
    else
      error_message = "#{t('messages.save_error')}: #{date_range.errors.full_messages.join(', ')}"
      redirect_to root_path(locale: params[:locale]), alert: error_message
    end
  rescue ArgumentError
    redirect_to root_path(locale: params[:locale]), alert: t('messages.invalid_date_format')
  end
  
  private
  
  def range_conflicts_with_bookings?(start_date, end_date, booked_dates)
    # Check if any date in the proposed range (excluding start and end) is already booked
    (start_date + 1.day...end_date).any? { |date| booked_dates.include?(date) }
  end
  
  # Helper method to get the current access key from multiple sources
  def get_current_access_key
    Rails.logger.info "=== TRYING TO GET ACCESS KEY USING MULTIPLE METHODS ==="
    
    # Method 1: Try getting the access key ID from the session
    access_key_id = session[:access_key_id]
    Rails.logger.info "=== METHOD 1: SESSION ACCESS_KEY_ID: #{access_key_id.inspect} ==="
    
    if access_key_id.present?
      access_key = AccessKey.find_by(id: access_key_id)
      Rails.logger.info "=== METHOD 1 RESULT: #{access_key.inspect} ==="
      return access_key if access_key.present?
    end
    
    # Method 1b: Try getting the access key ID from cookies
    cookie_access_key_id = cookies.signed[:access_key_id]
    Rails.logger.info "=== METHOD 1B: COOKIE ACCESS_KEY_ID: #{cookie_access_key_id.inspect} ==="
    
    if cookie_access_key_id.present?
      access_key = AccessKey.find_by(id: cookie_access_key_id)
      Rails.logger.info "=== METHOD 1B RESULT: #{access_key.inspect} ==="
      
      # If found in cookie but not in session, restore to session
      if access_key.present? && session[:access_key_id].blank?
        session[:access_key_id] = access_key.id
        Rails.logger.info "=== RESTORED ACCESS_KEY_ID TO SESSION FROM COOKIE ==="
      end
      
      return access_key if access_key.present?
    end
    
    # Method 2: If we know we're authenticated, try to find the active access key
    if session[:authenticated]
      Rails.logger.info "=== METHOD 2: USER IS AUTHENTICATED, LOOKING FOR ACTIVE ACCESS KEY ==="
      access_key = AccessKey.where(active: true).first
      Rails.logger.info "=== METHOD 2 RESULT: #{access_key.inspect} ==="
      
      # Save this for future use if found
      if access_key.present?
        session[:access_key_id] = access_key.id
        cookies.signed[:access_key_id] = {
          value: access_key.id,
          expires: ApplicationController::AUTH_COOKIE_EXPIRY.from_now,
          httponly: true,
          secure: Rails.env.production?
        }
        Rails.logger.info "=== SAVED FOUND ACCESS KEY TO SESSION AND COOKIE ==="
      end
      
      return access_key if access_key.present?
    end
    
    # Method 3: If all else fails, use the first access key (for testing only)
    Rails.logger.info "=== METHOD 3: FALLING BACK TO FIRST ACCESS KEY ==="
    access_key = AccessKey.first
    Rails.logger.info "=== METHOD 3 RESULT: #{access_key.inspect} ==="
    
    # Save this for future use if found
    if access_key.present?
      session[:access_key_id] = access_key.id
      cookies.signed[:access_key_id] = {
        value: access_key.id,
        expires: ApplicationController::AUTH_COOKIE_EXPIRY.from_now,
        httponly: true,
        secure: Rails.env.production?
      }
      Rails.logger.info "=== SAVED FALLBACK ACCESS KEY TO SESSION AND COOKIE ==="
    end
    
    # Return whatever we found (may be nil)
    access_key
  end
end
