class AddMessageFieldToImportLineReport < ActiveRecord::Migration[8.0]
  def change
    add_column :import_line_reports, :message, :string
  end
end
