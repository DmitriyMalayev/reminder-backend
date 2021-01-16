class CalendarSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :title
end