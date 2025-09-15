class Drawing < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :label, inclusion: { in: 0..9, allow_nil: true }
end
