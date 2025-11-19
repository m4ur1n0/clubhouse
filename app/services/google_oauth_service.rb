class GoogleOauthService
    TOKEN_URL = "https://oauth2.googleapis.com/token"

    def self.refresh!(user)
        return unless user.google_refresh_token.present?

        payload = {
            client_id: ENV.fetch("GOOGLE_CLIENT_ID"),
            client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET"),
            refresh_token: user.google_refresh_token,
            grant_type: "refresh_token"
        }
        response = HTTParty.post(
            TOKEN_URL,
            body: URI.encode_www_form(payload),
            headers: { "Content-Type" => "application/x-www-form-urlencoded" }
        )

        if response.success?
            user.update(
                google_access_token: response["access_token"],
                google_token_expires_at: Time.current + response["expires_in"].to_i
            )
        else
            Rails.logger.error("Failed to refresh Google access token for user #{user.id}: #{response.body}")
        end
    end
end
