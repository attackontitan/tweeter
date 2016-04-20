class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.string :keywords
      t.string :hash_tag
      t.string :handle

      t.timestamps
    end
  end
end
