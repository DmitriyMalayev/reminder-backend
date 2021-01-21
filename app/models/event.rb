class Event < ApplicationRecord
  belongs_to :user
  belongs_to :calendar
  validates :name, :notes, uniqueness: true, presence: true 
end
