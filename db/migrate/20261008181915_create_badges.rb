class CreateBadges < ActiveRecord::Migration[8.1]
  def change
    create_table :badges, id: :uuid do |t|
      t.string :name
      t.text :description
      t.string :icon

      t.timestamps
    end
  end
end
