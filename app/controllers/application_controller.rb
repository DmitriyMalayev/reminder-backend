class ApplicationController < ActionController::API
    def current_user
        User.first
    end
end

# We have one user and it has many calendars and has many events 
# first returns the first element of an element 