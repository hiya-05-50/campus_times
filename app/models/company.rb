class Company < ApplicationRecord
  has_many :placement_drives, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
