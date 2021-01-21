class Calendar < ApplicationRecord
  belongs_to :user
  has_many :events
  validates :title, uniqueness: true, presence: true
end
