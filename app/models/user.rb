class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :clubs, through: :memberships
  has_many :players, dependent: :nullify

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }

  def full_name
    "#{first_name} #{last_name}"
  end
end
