class BackfillLikeCountsForComments < ActiveRecord::Migration[7.1]
  def up
    Comment.find_each do |comment|
      Comment.reset_counters(comment.id, :likes)
    end
  end
end
