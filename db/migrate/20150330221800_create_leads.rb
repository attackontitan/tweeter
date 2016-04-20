class CreateLeads < ActiveRecord::Migration
  def change
    create_table :leads do |t|
      t.integer :tweet_id
      t.string :webinar_title
      t.string :link
      t.string :email
      t.string :type_cd

      t.timestamps
    end
  end
end
