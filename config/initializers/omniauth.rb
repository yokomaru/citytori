Rails.application.config.middleware.use OmniAuth::Builder do
  google_credentials = Rails.application.credentials.google
  if google_credentials.nil?
    raise "Google OAuth credentials not configured. Run `bin/rails credentials:edit --environment #{Rails.env}` and add a `google` section with `client_id` and `client_secret`."
  end

  provider :google_oauth2,
          google_credentials[:client_id],
          google_credentials[:client_secret]
end

OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)

OmniAuth.config.on_failure = lambda do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end
