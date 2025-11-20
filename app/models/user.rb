class User < ApplicationRecord
  has_secure_password validations: false # We'll handle password validation manually
  
  validates :email, presence: true, uniqueness: true
  validates :provider, presence: true, inclusion: { in: %w[google password] }
  
  # Provider-specific validations
  validates :google_id, uniqueness: { allow_nil: true }
  validates :google_id, presence: true, if: -> { provider == 'google' }
  validates :password, presence: true, length: { minimum: 6 }, if: -> { provider == 'password' && password.present? }
  validates :password_digest, presence: true, if: -> { provider == 'password' }

  has_many :clubs, dependent: :nullify # clubs they created
  has_many :memberships, dependent: :destroy
  has_many :member_clubs, through: :memberships, source: :club
  has_many :chat_messages, dependent: :destroy


  def self.from_omniauth(auth)
    where(google_id: auth.uid).first_or_create do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.avatar_url = auth.info.image
      user.provider = 'google'
    end
  end

  def self.from_google!(data)
    user = find_or_initialize_by(google_id: data["id"])
    user.name = data["name"]
    user.email = data["email"]
    user.avatar_url = data["picture"]
    user.provider = 'google'
    user.save!
    user
  end

  def owns?(club)
    club.user_id == self.id
  end

  def member_of?(club)
    member_clubs.exists?(club.id)
  end

  def google_connected?
    google_access_token.present?
  end
  
  def google_provider?
    provider == 'google'
  end
  
  def password_provider?
    provider == 'password'
  end
end
