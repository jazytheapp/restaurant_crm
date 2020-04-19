# frozen_string_literal: true

class Restaurant < ActiveRecord::Base
  WHITE_FIELDS = %w[name work_hour_start work_hour_stop].freeze
  has_many :tables, dependent: :destroy

  validates :name, :work_hour_start, :work_hour_stop, presence: true
  validate :validate_hours

  def to_json(*_args)
    as_json(only: %i[id name])
  end

  def is_time_between_work_hours?(time)
    time.hour.between?(work_hour_start, work_hour_stop)
  end

  private

  def validate_hours
    unless work_hour_start.nil? || work_hour_start.between?(0, 24)
      errors.add(:work_hour_start, 'wrong time')
    end

    unless work_hour_stop.nil? || work_hour_stop.between?(0, 24)
      errors.add(:work_hour_stop, 'wrong time')
    end
  end
end
