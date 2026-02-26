class EventCourt < ApplicationRecord
  belongs_to :event
  belongs_to :court

  validates :court_id, uniqueness: { scope: :event_id }
end
