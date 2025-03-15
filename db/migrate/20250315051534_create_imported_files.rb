class CreateImportedFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :imported_files do |t|
      t.string :name
      t.integer :total_lines, default: 0

      t.timestamps
    end
  end
end
