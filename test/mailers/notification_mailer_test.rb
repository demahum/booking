require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  test "reservation_created" do
    mail = NotificationMailer.reservation_created
    assert_equal "Reservation created", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
