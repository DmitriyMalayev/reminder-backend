class CalendarsController < ApplicationController
  before_action :set_calendar, only: [:show, :update, :destroy]

  # GET /calendars
  def index
    @calendars = current_user.calendars
    render json: @calendars 
    # render json: CalendarSerializer.new(@calendars).serializable_hash[:data].map{|info| info[attributes]}
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
      params.require(:calendar).permit(:name, :user_id)
    end
end
