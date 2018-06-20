class Calendarupdate < ApplicationRecord
  has_many :lessons

  monetize :price_cents

  validates :price_cents, presence: true, numericality: { greater_than: 0 , message: 'doit être un entier supérieur à 0' }
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: 'doit être un entier supérieur à 0' }
  validates :name, presence: :true
end
