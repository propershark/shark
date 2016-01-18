class ConvertArrivingAtAndDepartedAtToIntegers < ActiveRecord::Migration
  def up
    change_column :vehicles, :arriving_at, :integer
    change_column :vehicles, :departed_at, :integer
  end

  def down
    change_column :vehicles, :arriving_at, :timestamp
    change_column :vehicles, :departed_at, :timestamp
  end
end
