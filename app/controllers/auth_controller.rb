class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback, :failure]

  def new
    client_id = ENV.fetch("GOOGLE_CLIENT_ID")
    redirect_uri = 'http://localhost:3000/auth/google_oauth2/callback'
    scope = 'openid email profile'
    state = SecureRandom.hex(16)
    
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
    
    if code.present?
      # Exchange code for access token
      token_response = HTTParty.post('https://oauth2.googleapis.com/token', {
        body: {
          client_id: ENV.fetch("GOOGLE_CLIENT_ID"),
          client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET"),
          code: code,
          grant_type: 'authorization_code',
          redirect_uri: 'http://localhost:3000/auth/google_oauth2/callback'
        }
      })
      
      if token_response.success?
        access_token = token_response['access_token']
        
        # Get user info from Google
        user_response = HTTParty.get('https://www.googleapis.com/oauth2/v2/userinfo', {
          headers: { 'Authorization' => "Bearer #{access_token}" }
        })
        
        if user_response.success?
          user_data = user_response.parsed_response
          user = User.find_or_create_by(google_id: user_data['id']) do |u|
            u.name = user_data['name']
            u.email = user_data['email']
            u.avatar_url = user_data['picture']
          end
          
          session[:user_id] = user.id
          redirect_to root_path, notice: 'Successfully signed in!'
        else
          redirect_to root_path, alert: 'Failed to get user information!'
        end
      else
        redirect_to root_path, alert: 'Failed to exchange code for token!'
      end
    else
      redirect_to root_path, alert: 'No authorization code received!'
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
