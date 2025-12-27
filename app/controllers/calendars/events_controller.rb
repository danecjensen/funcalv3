class Calendars::EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_calendar
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    authorize @calendar, :show?
    @events = @calendar.events.upcoming.includes(:calendar)
  end

  def show
    authorize @event
  end

  def new
    authorize @calendar, :update?
    @event = @calendar.events.build
  end

  def create
    authorize @calendar, :update?
    @event = @calendar.events.build(event_params)

    if @event.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to [@calendar, @event], notice: "Event created!" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @event
  end

  def update
    authorize @event
    if @event.update(event_params)
      redirect_to [@calendar, @event], notice: "Event updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @event
    @event.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to calendar_events_path(@calendar), notice: "Event deleted." }
    end
  end

  private

  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end

  def set_event
    @event = @calendar.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :starts_at, :ends_at, :location, :all_day, :timezone)
  end
end
