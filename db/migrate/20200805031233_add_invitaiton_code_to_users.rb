class AddInvitaitonCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :invitation_code, :string
    add_index :users, :invitation_code
  end
end
