class CalendarSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name
end
