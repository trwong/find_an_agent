class AddProfilePictureToAgent < ActiveRecord::Migration[5.1]
  def change
    add_column :agents, :profile_picture, :string, default: "https://res.cloudinary.com/trwong/image/upload/v1540503263/main-qimg-87001d2ce810c2f48c97032cbc905939_ynkjeu.png"
  end
end
