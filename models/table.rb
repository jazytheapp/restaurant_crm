# frozen_string_literal: true

class Table < ActiveRecord::Base
  WHITE_FIELDS = %w[restaurant_id description].freeze

  belongs_to :restaurant

  has_many :reservations, dependent: :destroy

  validates :restaurant, :description, presence: true

  def to_json(*_args)
    as_json(only: %i[id description])
  end
end
