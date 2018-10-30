class RemoveNotNullOnTranslatedFields < ActiveRecord::Migration[5.2]
  def change
    change_column_null :ceramiques, :name, true
    change_column_null :ceramiques, :description, true
    change_column_null :categories, :name, true
    change_column_null :articles, :content, true
  end
end
