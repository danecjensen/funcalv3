class CalendarsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_calendar, only: [:show, :edit, :update, :destroy]

  def index
    @calendars = policy_scope(Calendar).includes(:user, :events)
  end

  def show
    authorize @calendar
  end

  def new
    @calendar = Calendar.new
  end

  def create
    @calendar = Current.user.calendars.build(calendar_params)

    if @calendar.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @calendar, notice: "Calendar created!" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @calendar
  end

  def update
    authorize @calendar
    if @calendar.update(calendar_params)
      redirect_to @calendar, notice: "Calendar updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @calendar
    @calendar.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to calendars_path, notice: "Calendar deleted." }
    end
  end

  private

  def set_calendar
    @calendar = Calendar.find(params[:id])
  end

  def calendar_params
    params.require(:calendar).permit(:name, :description, :color, :visibility)
  end
end
