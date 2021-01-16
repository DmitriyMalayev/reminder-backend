class EventsController < ApplicationController
  before_action :set_event, only: [:show, :update, :destroy]

  # GET /events
  def index
    @events = current_user.events
    render json: EventSerializer.new(@events).serializable_hash[:data].map{|info| info[:attributes]}
  end

  # GET /events/1
  def show
    render json: @event
  end

  # POST /events
  def create
    @event = current_user.events.build(event_params)
    if @event.save
      render json: EventSerializer.new(@event).serializable_hash[:data][:attributes], status: :created
    else
      render json: @event.errors.full_messages.to_sentence, status: :unprocessable_entity
    end 
  end 

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      render json: EventSerializer.new(@event).serializable_hash[:data][:attributes], status: :ok
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = current_user.events.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def event_params
      params.require(:event).permit(:name, :start_time, :end_time, :notes, :calendars, :completed, :user_id, :calendar_id)
    end
end