# frozen_string_literal: true

class Reservation < ActiveRecord::Base
  WHITE_FIELDS = %w[user_id table_id start_at stop_at].freeze

  belongs_to :table
  belongs_to :user

  validates :table, :user, :start_at, :stop_at, presence: true
  validate :validate_time
  validate :validate_restaurant, on: :create
  validate :validate_other_reservations, on: :update

  def to_json(*_args)
    d = as_json(only: %i[id user_id table_id])
    d['start_at'] = start_at.to_i
    d['stop_at'] = stop_at.to_i
    d
  end

  private

  def validate_time
    if start_at > stop_at
      errors.add(:stop_at, 'must be greater than the start_at')
    end
    if (stop_at - start_at) % (30 * 60) != 0
      errors.add(:stop_at, 'should be a multiple of 30 minutes from the start_at')
    end
  end

  def validate_restaurant
    if table_id.nil?
      errors.add(:table_id, 'required')
      return
    end

    table = Table.includes(:restaurant).find(table_id)

    unless table.restaurant.is_time_between_work_hours?(start_at)
      errors.add(:start_at, 'restaurant not work')
    end

    unless table.restaurant.is_time_between_work_hours?(stop_at)
      errors.add(:stop_at, 'restaurant not work')
    end

    reservations_in_time = \
      Reservation.includes(table: [:restaurant])
                 .where('start_at <= ?', start_at)
                 .where('stop_at > ?', start_at)
                 .or(
                   Reservation.includes(table: [:restaurant])
                              .where('start_at <= ?', stop_at)
                              .where('stop_at >= ?', stop_at)
                 )

    reservations_in_time.each do |r|
      if r.table_id == table_id
        errors.add(:table_id, 'already reserved at this time')
      end
      if r.user_id == user_id && r.table.restaurant.id != table.restaurant.id
        errors.add(:user_id, 'has a reserved table in another restaurant')
      end
    end
  end

  def validate_other_reservations
    table = Table.includes(:restaurant).find(table_id)

    unless table.restaurant.is_time_between_work_hours?(start_at)
      errors.add(:start_at, 'restaurant not work')
    end

    unless table.restaurant.is_time_between_work_hours?(stop_at)
      errors.add(:stop_at, 'restaurant not work')
    end

    if Reservation.where('start_at <= ?', start_at)
                  .where('stop_at > ?', start_at)
                  .or(
                    Reservation.where('start_at <= ?', stop_at)
                               .where('stop_at >= ?', stop_at)
                  )
                  .where(table_id: table_id)
                  .where.not(id: id)
                  .any?

      errors.add(:start_at, 'other reservations exists')
    end
  end
end
