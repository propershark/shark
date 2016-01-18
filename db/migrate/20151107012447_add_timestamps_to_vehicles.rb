class AddTimestampsToVehicles < ActiveRecord::Migration
  def change
    change_table :vehicles do |t|
      t.integer     :last_update
      t.integer     :started_at
      # Also add a trip association
      t.belongs_to  :trip,          index: true
    end
  end
end
