user = User.first 

personal_calendar = user.calendars.find_or_create_by(title: "Personal")
work_calendar = user.calendars.find_or_create_by(title: "Work")
private_calendar = user.calendars.find_or_create_by(title: "Private")

events = user.events.find_or_create_by(
    name: "New Event", 
    start_time: "2021-01-17T19:16:00.000Z", 
    end_time: "2021-01-17T19:17:00.000Z", 
    notes: "aaaaaa", 
    completed: true)
