class Club < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :players, dependent: :destroy
  has_many :courts, dependent: :destroy
  has_many :grade_levels, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers, and hyphens" }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  private

  def generate_slug
    base = name.strip.split.first.downcase.gsub(/[^a-z0-9]/, "")
    loop do
      candidate = "#{base}-#{SecureRandom.alphanumeric(6).downcase}"
      break self.slug = candidate unless Club.exists?(slug: candidate)
    end
  end
end
