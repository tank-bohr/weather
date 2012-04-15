class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.string :client_id
      t.string :city
      t.string :url

      t.timestamps
    end

    add_index(:favorites, [:client_id, :url], :unique => true)
  end
end
