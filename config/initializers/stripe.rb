if ENV["ASSET_COMPILE"].blank?
  Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
end
