class Club < ApplicationRecord
    belongs_to :user
    has_many :events, dependent: :destroy
    has_many :memberships, dependent: :destroy
    has_many :members, through: :memberships, source: :user
    has_many :chat_messages, dependent: :destroy

    validates :name, presence: true
end
