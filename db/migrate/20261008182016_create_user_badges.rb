class CreateUserBadges < ActiveRecord::Migration[8.1]
  def change
    create_table :user_badges, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true
      t.references :badge, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
