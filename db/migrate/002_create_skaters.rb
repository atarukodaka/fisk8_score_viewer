class CreateSkaters < ActiveRecord::Migration
  def change
    create_table :skaters do |t|
      t.string :name
      t.string :nation
      t.string :category

      t.integer :isu_number
      t.string :isu_bio

      ## optional keys
      t.date :birthday
      t.string :coach
      t.string :choreographer
      t.string :hobbies

      t.string :height
      t.string :club

      t.timestamps
    end
  end
end
