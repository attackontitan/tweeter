class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :tweet_id
      t.timestamp :tweeted_on
      t.integer :query_id
      t.string :handle
      t.text :message

      t.timestamps
    end
  end
end
