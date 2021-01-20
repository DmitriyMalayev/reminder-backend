class Event < ApplicationRecord
  belongs_to :user
  belongs_to :calendar
  # validates :name, :notes, unique: true, presence: true 
end
