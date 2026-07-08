Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
          Rails.application.credentials.google[:client_id],
          Rails.application.credentials.google[:client_secret]
end
OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)
