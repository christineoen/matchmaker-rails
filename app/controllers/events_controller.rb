class EventsController < ApplicationController
  include ClubScoped

  before_action :set_event, only: [ :show, :edit, :update, :destroy, :courts, :update_courts, :players_setup, :update_players_setup ]

  def index
    @events = @club.events.order(started_at: :desc)
  end

  def new
    @event = Event.new(club: @club, started_at: Time.current)
  end

  def create
    @event = Event.new(event_params.merge(club: @club))
    if @event.save
      redirect_to courts_club_event_path(@club, @event)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to courts_club_event_path(@club, @event)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def courts
    @courts = @club.courts
    @selected_court_ids = @event.court_ids
  end

  def update_courts
    @event.event_courts.destroy_all
    Array(params[:court_ids]).each { |id| @event.event_courts.create(court_id: id) }
    redirect_to players_setup_club_event_path(@club, @event)
  end

  def players_setup
    @players = @club.players.includes(:grade_level).order(:name)
    @selected_player_ids = @event.player_ids
    @grade_levels = @club.grade_levels.ordered
  end

  def update_players_setup
    selected_ids = Array(params[:player_ids]).map(&:to_i)
    existing_ids = @event.player_ids

    (selected_ids - existing_ids).each { |id| @event.event_players.create(player_id: id) }
    @event.event_players.where(player_id: existing_ids - selected_ids).destroy_all

    (params[:player_edits] || {}).each do |player_id, edits|
      player = @club.players.find_by(id: player_id)
      player&.update(edits.permit(:grade_level_id, :grade_offset, :avoids_hard_courts))
    end

    redirect_to club_event_path(@club, @event)
  end

  def show
    @event_players = @event.event_players.includes(player: :grade_level).order("players.name")
  end

  def destroy
    @event.destroy
    redirect_to club_events_path(@club), notice: "Event deleted."
  end

  private

  def set_event
    @event = @club.events.find(params[:id])
  end

  def event_params
    params.expect(event: [ :label, :gender_format, :started_at ])
  end
end
