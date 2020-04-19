# frozen_string_literal: true

class User < ActiveRecord::Base
  WHITE_FIELDS = ['name'].freeze

  has_many :reservations, dependent: :destroy

  validates :name, presence: true

  def to_json(*_args)
    as_json(only: %i[id name])
  end
end
