class AddProfileFieldsToUsers2 < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :sns_links, :text, array: true, default: []
  end
end
