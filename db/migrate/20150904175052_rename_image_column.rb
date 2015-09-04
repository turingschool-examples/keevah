class RenameImageColumn < ActiveRecord::Migration
  def up
    remove_column :loan_requests, :picture_file_name
    add_column :loan_requests, :image_url, :string
  end

  def down
    add_column :loan_requests, :picture_file_name, :string
    remove_column :loan_requests, :image_url
  end
end
