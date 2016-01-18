class ConvertStopTimesTimesToIntegers < ActiveRecord::Migration
  def up
    change_column :stop_times, :departure_time, :integer
    change_column :stop_times, :arrival_time, :integer
  end

  def down
    change_column :stop_times, :departure_time, :time
    change_column :stop_times, :arrival_time, :time
  end
end
