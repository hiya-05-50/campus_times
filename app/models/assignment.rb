class Assignment < ApplicationRecord
  belongs_to :course
  has_many :submissions, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :deadline, presence: true
  validates :max_marks, presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  scope :published, -> { where(published: true) }

  def past_deadline?
    deadline < Time.current
  end
end
