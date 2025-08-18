class Sample < ApplicationRecord
  validates :label, inclusion: { in: 0..9 }
  validates :path, presence: true
end
