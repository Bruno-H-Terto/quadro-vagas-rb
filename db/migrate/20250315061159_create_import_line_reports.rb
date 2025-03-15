class CreateImportLineReports < ActiveRecord::Migration[8.0]
  def change
    create_table :import_line_reports do |t|
      t.integer :status, default: 0
      t.integer :line
      t.string :command
      t.references :imported_file, null: false, foreign_key: true

      t.timestamps
    end
  end
end
