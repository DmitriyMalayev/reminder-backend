class CalendarsController < ApplicationController
  before_action :set_calendar, only: [:show, :update, :destroy]

  # GET /calendars
  def index   #If status code isn't specified it will use the status code of 200 unless there is an error      
    @calendars = current_user.calendars 
      # binding.pry
    render json: CalendarSerializer.new(@calendars).serializable_hash[:data].map{|info| info[:attributes]}

  end


  # GET /calendars/1
  def show
    render json: @calendar
  end

  # POST /calendars
  def create
    @calendar = current_user.calendars.build(calendar_params)
    if @calendar.save 
      render json: CalendarSerializer.new(@calendar).serializable_hash[:data][:attributes], status: :created, location: @calendar
    else 
      render json: @calendar.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end 

  # PATCH/PUT /calendars/1
  def update
    if @calendar.update(calendar_params)
      render json: CalendarSerializer.new(@calendar).serializable_hash[:data][:attributes], status: :ok, location: @calendar
    else
      render json: @calendar.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end

  # DELETE /calendars/1
  def destroy
    @calendar.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_calendar
      @calendar = current_user.calendars.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def calendar_params
      params.require(:calendar).permit(:title) 
      # The user id will be assigned by the current_user
    end
end

# serializable_hash 
# Before the serializer we had an array of objects and after we have a data property pointing to an array of objects. Each object has id, type and attribute. We need to things in attributes. serializable_hash returns a serialized hash of your object. We use the brackets method [] to access the key in a hash. 


#full_messages  => Returns all the full error messages in an array 
# to_sentence(options = {})
# Converts the array to a comma-separated sentence where the last element is joined by the connector word. 
# ['one', 'two'].to_sentence  => "one and two" 
# ['one', 'two', 'three'].to_sentence  => "one, two, and three"


# full_messages() public
# Returns all the full error messages in an array.


# render :json 
# JSON is a JS data format used by AJAX Libraries. Rails has built-in support for converting objects to JSON and rendering that JSON back to the browser. 
# We don't need to use to_json when we use :json render will automatically use to_json for us. 