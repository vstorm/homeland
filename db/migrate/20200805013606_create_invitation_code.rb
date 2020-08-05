class CreateInvitationCode < ActiveRecord::Migration[6.0]
  def change
    create_table :invitation_codes do |t|
      t.integer :user_id, null: false
      t.string :code, null: false
    end

    add_index :invitation_codes, :user_id
    add_index :invitation_codes, :code
  end
end
