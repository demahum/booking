# Be sure to restart your server when you modify this file.

# Configure the session to use cookies that last longer
Rails.application.config.session_store :cookie_store, 
                                       key: '_booking_session',
                                       expire_after: 2.weeks,
                                       secure: Rails.env.production?,
                                       httponly: true