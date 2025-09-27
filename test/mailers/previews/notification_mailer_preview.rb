# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/reservation_created
  def reservation_created
    # Create a sample date range and access key for the preview
    date_range = DateRange.new(
      start_date: Date.today,
      end_date: Date.today + 5.days
    )
    
    access_key = AccessKey.first || AccessKey.new(key: "sample-key-123", active: true)
    
    NotificationMailer.reservation_created(date_range, access_key)
  end
end
