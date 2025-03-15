class ImportLineReport < ApplicationRecord
  belongs_to :imported_file

  enum :status, {
    waiting: 0, success: 5, failed: 10
  }

  after_create_commit -> { 
    Rails.logger.debug "Broadcasting append to import_file_#{imported_file.id}"
    broadcast_replace_to "imported_file_#{imported_file.id}", target: "import_line_reports", partial: "imported_files/progress", locals: { imported_file: self.imported_file }
  }
end
