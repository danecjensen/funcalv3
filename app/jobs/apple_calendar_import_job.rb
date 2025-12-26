class AppleCalendarImportJob < ApplicationJob
  queue_as :default

  # Import events from an Apple Calendar (iCal format) into the database
  #
  # @param calendar_data [String] iCal content (raw .ics data) or URL to fetch
  # @param user_id [Integer] User ID who will own the imported events
  # @param options [Hash] Optional settings:
  #   - skip_past_events: Boolean - skip events that have already ended (default: false)
  #   - deduplicate: Boolean - skip events with matching title and start time (default: true)
  #
  def perform(calendar_data, user_id, options = {})
    @user = User.find(user_id)
    @options = options.with_defaults(skip_past_events: false, deduplicate: true)

    ical_content = fetch_calendar_content(calendar_data)
    calendars = Icalendar::Calendar.parse(ical_content)

    imported_count = 0

    calendars.each do |calendar|
      calendar.events.each do |ical_event|
        next if skip_event?(ical_event)

        create_event_from_ical(ical_event)
        imported_count += 1
      end
    end

    Rails.logger.info "[AppleCalendarImportJob] Imported #{imported_count} events for user #{user_id}"
    imported_count
  end

  private

  def fetch_calendar_content(calendar_data)
    if calendar_data.start_with?("http://", "https://", "webcal://")
      url = calendar_data.gsub(/^webcal:\/\//, "https://")
      URI.open(url).read
    else
      calendar_data
    end
  end

  def skip_event?(ical_event)
    return true if @options[:skip_past_events] && event_ended?(ical_event)
    return true if @options[:deduplicate] && duplicate_event?(ical_event)
    false
  end

  def event_ended?(ical_event)
    end_time = ical_event.dtend || ical_event.dtstart
    return false unless end_time

    end_time.to_time < Time.current
  end

  def duplicate_event?(ical_event)
    title = extract_title(ical_event)
    starts_at = extract_datetime(ical_event.dtstart)

    return false unless title.present? && starts_at.present?

    Event.joins(:post)
         .where(posts: { creator_id: @user.id })
         .where(title: title, starts_at: starts_at)
         .exists?
  end

  def create_event_from_ical(ical_event)
    title = extract_title(ical_event)
    starts_at = extract_datetime(ical_event.dtstart)
    ends_at = extract_datetime(ical_event.dtend)
    all_day = all_day_event?(ical_event)
    location = ical_event.location&.to_s
    timezone = extract_timezone(ical_event)

    # Create a post to associate with the event (required by Event model)
    post = Post.create!(
      creator: @user,
      body: build_event_body(ical_event)
    )

    # Create the event record
    Event.create!(
      post: post,
      title: title,
      starts_at: starts_at,
      ends_at: ends_at,
      all_day: all_day,
      location: location,
      timezone: timezone
    )
  end

  def extract_title(ical_event)
    ical_event.summary&.to_s.presence || "Untitled Event"
  end

  def extract_datetime(ical_datetime)
    return nil unless ical_datetime

    if ical_datetime.is_a?(Icalendar::Values::Date)
      ical_datetime.to_date.beginning_of_day
    else
      ical_datetime.to_time
    end
  end

  def all_day_event?(ical_event)
    ical_event.dtstart.is_a?(Icalendar::Values::Date)
  end

  def extract_timezone(ical_event)
    dtstart = ical_event.dtstart
    return nil unless dtstart.respond_to?(:ical_params)

    tzid = dtstart.ical_params&.dig("tzid")&.first
    tzid&.to_s
  end

  def build_event_body(ical_event)
    parts = []
    parts << ical_event.summary.to_s if ical_event.summary.present?
    parts << ical_event.description.to_s if ical_event.description.present?
    parts.join("\n\n").presence || "Imported from Apple Calendar"
  end
end
