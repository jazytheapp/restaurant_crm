class Restaurant < ActiveRecord::Base
  WHITE_FIELDS = ['name', 'work_hour_start', 'work_hour_stop']
  def to_json
    self.as_json(only: [:id, :name])
  end
end
