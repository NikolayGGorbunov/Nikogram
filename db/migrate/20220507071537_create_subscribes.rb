class CreateSubscribes < ActiveRecord::Migration[7.0]
  def change
    create_table :subscribes do |t|
      t.integer :subscriber_id, index: true
      t.integer :subscribed_id, index: true

      t.timestamps
    end
    add_index :subscribes, [:subscriber_id, :subscribed_id], unique: true
  end
end
