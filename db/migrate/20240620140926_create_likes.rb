class CreateLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :likes do |t|
      t.references :likeable, polymorphic: true, null: false
      t.references :user, foreign_key: true, null: false
      t.timestamps
    end

    add_index :likes, %i[user_id likeable_type likeable_id], unique: true
  end
end
