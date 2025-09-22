class HomeController < ApplicationController
  def index
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
      redirect_to root_path, alert: t('messages.select_complete_range')
      return
    end
    
    # Ensure start_date is before end_date
    if start_date > end_date
      start_date, end_date = end_date, start_date
    end
    
    # Create the date range record
    date_range = DateRange.new(start_date: start_date, end_date: end_date)
    
    if date_range.save
      redirect_to root_path, notice: t('messages.range_saved_success')
    else
      error_message = "#{t('messages.save_error')}: #{date_range.errors.full_messages.join(', ')}"
      redirect_to root_path(start_date: start_date, end_date: end_date), alert: error_message
    end
  rescue ArgumentError
    redirect_to root_path, alert: t('messages.invalid_date_format')
  end
  
  private
  
  def range_conflicts_with_bookings?(start_date, end_date, booked_dates)
    # Check if any date in the proposed range (excluding start and end) is already booked
    (start_date + 1.day...end_date).any? { |date| booked_dates.include?(date) }
  end
end
