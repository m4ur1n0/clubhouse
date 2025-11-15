module BackendRequestHelpers
  include Rack::Test::Methods
  include Rails.application.routes.url_helpers

  def app
    Rails.application
  end

  def stub_current_user(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_return(user.present?)
  end

  def follow_redirect_chain!
    while last_response.redirect?
      follow_redirect!
    end
  end
end

World(BackendRequestHelpers)
