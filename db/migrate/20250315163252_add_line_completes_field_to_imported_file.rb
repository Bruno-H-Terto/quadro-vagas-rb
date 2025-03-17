class AddLineCompletesFieldToImportedFile < ActiveRecord::Migration[8.0]
  def change
    add_column :imported_files, :complete_lines, :integer, default: 0
  end
end
