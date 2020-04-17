class Table < ActiveRecord::Base
  WHITE_FIELDS = ['restaurant_id', 'description']
  belongs_to :restaurant
  has_many :reservations, dependent: :destroy
  validates :restaurant, presence: true
  def to_json
    self.as_json(only: [:id, :description])
  end
end
