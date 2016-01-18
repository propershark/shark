class InitialTableSetup < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      # Identifying information
      # CityBus and DoubleMap have different ID systems, meaning we need to
      # keep track of both to be able to pull data consistently. In addition to
      # this, a normal `id` column will also be generated for local tracking.
      # This system also follows for every other table listed here.
      t.string      :citybus_id,          index: true
      t.integer     :doublemap_id,        index: true
      # Descriptive information
      t.string      :long_name
      t.string      :short_name
      t.text        :description
      t.boolean     :active
      t.string      :color
      t.string      :url
      t.timestamp   :start_time
      t.timestamp   :end_time
      # Location information
      t.text        :path
      # created_at, updated_at
      t.timestamps  null: false
    end


    create_table :stops do |t|
      # Identifying information
      t.string      :citybus_id,          index: true
      t.integer     :doublemap_id,        index: true
      # Descriptive information
      t.string      :name
      t.string      :code
      t.text        :description
      # Location information
      t.decimal     :latitude,            index: true, null: false, precision: 6, scale: 4
      t.decimal     :longitude,           index: true, null: false, precision: 6, scale: 4
      # created_at, updated_at
      t.timestamps  null: false
    end
    add_index :stops, [:latitude, :longitude]

    create_table :vehicles do |t|
      # Identifying information
      t.string      :citybus_id,          index: true
      t.integer     :doublemap_id,        index: true
      # Descriptive information
      t.string      :name
      t.string      :code
      t.integer     :saturation
      t.belongs_to  :route,               index: true
      t.integer     :heading
      t.belongs_to  :next_stop,           index: true
      t.timestamp   :arriving_at
      t.belongs_to  :last_stop,           index: true
      t.timestamp   :departed_at
      # Location information
      t.decimal     :latitude,            index: true, null: false, precision: 6, scale: 4
      t.decimal     :longitude,           index: true, null: false, precision: 6, scale: 4
      # created_at, updated_at
      t.timestamps  null: false
    end
    add_index :vehicles, [:latitude, :longitude]
  end
end
