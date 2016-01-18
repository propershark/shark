class AddIsTimepointToStopTimes < ActiveRecord::Migration
  def change
    add_column :stop_times, :is_timepoint, :boolean
  end
end
