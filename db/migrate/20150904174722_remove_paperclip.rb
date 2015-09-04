class RemovePaperclip < ActiveRecord::Migration
  def up
    remove_column :loan_requests, :picture_content_type
    remove_column :loan_requests, :picture_file_size
    remove_column :loan_requests, :picture_updated_at
  end

  def down
    add_column :loan_requests, :picture_content_type, :string
    add_column :loan_requests, :picture_file_size, :integer
    add_column :loan_requests, :picture_updated_at, :datetime
  end
end
