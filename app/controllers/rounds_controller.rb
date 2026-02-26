class RoundsController < ApplicationController
  include ClubScoped
  before_action :set_event

  def create
    next_number = @event.rounds.maximum(:number).to_i + 1
    round_number = params[:round_number]&.to_i || next_number
    MatchGenerator.new(@event, round_number: round_number).call
    redirect_to club_event_path(@club, @event)
  end

  def destroy
    @event.rounds.find(params[:id]).destroy
    redirect_to club_event_path(@club, @event)
  end

  private

  def set_event = @event = @club.events.find(params[:event_id])
end
