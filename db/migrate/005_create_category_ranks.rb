class CreateCategoryRanks < ActiveRecord::Migration
  def change
    create_table :category_ranks do |t|
      t.string :category

      t.integer :rank
      t.string :skater_name
      t.float :points

      t.belongs_to :competition
    end
  end
end
