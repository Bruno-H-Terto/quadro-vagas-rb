class AddSuccessFieldsPerTypeToImportedFile < ActiveRecord::Migration[8.0]
  def change
    add_column :imported_files, :success_user, :integer, default: 0
    add_column :imported_files, :success_company_profile, :integer, default: 0
    add_column :imported_files, :success_job_posting, :integer, default: 0
  end
end
