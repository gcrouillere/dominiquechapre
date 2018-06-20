class Lesson < ApplicationRecord
  attr_accessor :calendar_update_ref

  belongs_to :user
  belongs_to :calendarupdate
  has_one :order

  validates :start, presence: true
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :student, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
