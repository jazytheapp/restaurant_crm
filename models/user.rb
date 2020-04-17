class User < ActiveRecord::Base
  WHITE_FIELDS = ['name']
  def to_json
    self.as_json(only: [:id, :name])
  end
end
