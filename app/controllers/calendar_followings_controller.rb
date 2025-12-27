class CalendarFollowingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_calendar

  def create
    @following = @calendar.calendar_followings.build(user: Current.user)
    authorize @following

    if @following.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @calendar, notice: "You are now following this calendar." }
      end
    else
      redirect_to @calendar, alert: @following.errors.full_messages.to_sentence
    end
  end

  def destroy
    @following = @calendar.calendar_followings.find_by!(user: Current.user)
    authorize @following

    @following.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @calendar, notice: "You are no longer following this calendar." }
    end
  end

  private

  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end
end
