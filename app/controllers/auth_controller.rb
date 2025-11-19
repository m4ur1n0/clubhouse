class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback, :failure]

  def new
    client_id = ENV.fetch("GOOGLE_CLIENT_ID")
    redirect_uri = Rails.env.production? ? "https://clubhouse-bb0e602288cc.herokuapp.com/auth/google_oauth2/callback" : 'http://localhost:3000/auth/google_oauth2/callback'
    scope = 'openid email profile https://www.googleapis.com/auth/calendar'
    state = SecureRandom.hex(16)
    session[:return_to] = params[:return_to] if params[:return_to].present?
    
    oauth_url = "https://accounts.google.com/o/oauth2/v2/auth?" +
                "client_id=#{client_id}&" +
                "redirect_uri=#{CGI.escape(redirect_uri)}&" +
                "scope=#{CGI.escape(scope)}&" +
                "response_type=code&" +
                "access_type=offline&" +
                "state=#{state}"
    
    redirect_to oauth_url, allow_other_host: true
  end

  def callback
    # Handle manual OAuth callback
    code = params[:code]
    state = params[:state]

    if code.blank?
        redirect_to root_path, alert: 'No authorization code received!'
        return
    end
    
    # eschange code for access and refresh
    token_payload = {
        client_id: ENV.fetch("GOOGLE_CLIENT_ID"),
        client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET"),
        code: code,
        grant_type: "authorization_code",
        redirect_uri: Rails.env.production? ?
        "https://clubhouse-bb0e602288cc.herokuapp.com/auth/google_oauth2/callback" :
        'http://localhost:3000/auth/google_oauth2/callback'
    }
    token_response = HTTParty.post(
        "https://oauth2.googleapis.com/token",
        body: URI.encode_www_form(token_payload),
        headers: { "Content-Type" => "application/x-www-form-urlencoded" }
    )

    unless token_response.success?
        redirect_to root_path, alert: 'Failed to obtain access token!'
        return
    end

    access_token = token_response["access_token"]
    refresh_token = token_response["refresh_token"]   # might be nil
    expires_in = token_response["expires_in"]
    expires_at = Time.current + expires_in.to_i

    # fetch google profile
    user_response = HTTParty.get("https://www.googleapis.com/oauth2/v2/userinfo", headers: {"Authorization" => "Bearer #{access_token}"})
    
    unless user_response.success?
        redirect_to root_path, alert: 'Failed to fetch user info!'
        return
    end

    user_data = user_response.parsed_response

    # find or create user and store tokens
    user = User.find_or_initialize_by(email: user_data["email"])
    user.name = user_data["name"]
    user.google_id = user_data["id"]
    user.avatar_url = user_data["picture"]

    user.google_access_token = access_token
    user.google_refresh_token = refresh_token if refresh_token.present?
    user.google_token_expires_at = expires_at

    if user.save
        session[:user_id] = user.id

        # redirect_to session.delete(:return_to) || root_path, notice: 'Successfully signed in with Google!'
        return_to = session.delete(:return_to)
        if return_to.present?
            # DO NOT show a notice, as RSVP has a more important notice
            redirect_to return_to
        else
            redirect_to root_path, notice: 'Successfully signed in with Google!'
        end


    else
        Rails.logger.error("Failed to save user: #{user.errors.full_messages.join(', ')}")
        redirect_to root_path, alert: 'Failed to save user!'
    end

  end

  def failure
    redirect_to root_path, alert: 'Authentication failed!'
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path, notice: 'Successfully signed out!'
  end
end
