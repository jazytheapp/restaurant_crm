class User < ActiveRecord::Base
  WHITE_FIELDS = ['name']
  has_many :reservations, dependent: :destroy
  def to_json
    self.as_json(only: [:id, :name])
  end
end
