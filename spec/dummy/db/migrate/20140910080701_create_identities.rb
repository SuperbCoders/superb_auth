class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.text :data

      t.timestamps
    end
    add_index :identities, :provider
    add_index :identities, :user_id
    add_index :identities, [:provider, :uid], unique: true
    add_index :identities, [:provider, :user_id], unique: true
  end
end
