class ChangeCalendar < ActiveRecord::Migration[5.2]
  def change
    add_column :calendarupdates, :available, :boolean
    add_monetize :calendarupdates, :price, currency: { present: false }
    add_reference :lessons, :calendarupdate, foreign_key: true
    add_column :calendarupdates, :capacity, :integer
    add_column :calendarupdates, :name, :string, null: false
  end
end
