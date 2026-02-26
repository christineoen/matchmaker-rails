module ClubScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_club
    before_action :require_club_admin
  end

  private

  def set_club
    @club = current_user.clubs.find(params[:club_id])
  end

  def require_club_admin
    unless current_user.memberships.find_by(club: @club)&.admin?
      redirect_to @club, alert: "Only club admins can do that."
    end
  end
end
