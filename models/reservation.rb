class Reservation < ActiveRecord::Base
  WHITE_FIELDS = ['user_id', 'table_id', 'start_at', 'stop_at']
  belongs_to :table
  belongs_to :user
  validates :table, :user, presence: true
  def to_json
    d = self.as_json(only: [:id, :user_id, :table_id])
    d['start_at'] = self.start_at.to_i
    d['stop_at'] = self.stop_at.to_i
    d
  end
end
