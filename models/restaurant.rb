class Restaurant < ActiveRecord::Base
  WHITE_FIELDS = ['name', 'work_hour_start', 'work_hour_stop']
  has_many :tables, dependent: :destroy
  def to_json
    self.as_json(only: [:id, :name])
  end
  def is_time_between_work_hours?(time_1, time_2)
    time_1.hour.between?(self.work_hour_start, self.work_hour_stop) &&
    time_2.hour.between?(self.work_hour_start, self.work_hour_stop)
  end
end
