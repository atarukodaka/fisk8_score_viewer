class CreateSkaters < ActiveRecord::Migration
  def change
    create_table :skaters do |t|
      t.string :name
      t.string :nation
      t.string :category
      t.date :birthday

      t.integer :isu_number
      t.string :isu_bio

      t.string :coach
      t.string :choreographer

      t.timestamps
    end
  end
end
