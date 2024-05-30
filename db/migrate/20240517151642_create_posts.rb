class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.datetime :published_at
      t.belongs_to :user
      t.timestamps
    end
  end
end
