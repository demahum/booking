class NotificationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.reservation_created.subject
  #
  def reservation_created(date_range, access_key)
    @date_range = date_range
    @access_key = access_key
    @created_at = Time.current

    mail(
      to: "muhamedbasketball@gmail.com",
      subject: "New Reservation Created: #{@date_range.start_date.strftime('%b %d')} - #{@date_range.end_date.strftime('%b %d, %Y')}"
    )
  end
end
