class ChangeUsersIdToCustomNumericId < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :id, nil
  end
end
