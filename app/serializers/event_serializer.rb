class EventSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :start_time, :end_time, :notes, :calendar
  attribute :calendar_title do |object| 
    object.calendar.title  
  end 
  belongs_to :calendar 
end


