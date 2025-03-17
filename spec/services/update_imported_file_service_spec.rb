require 'rails_helper'

RSpec.describe UpdateImportedFileService do
  it 'increments all fields correctly' do
    admin = create(:user, role: 'admin')
    file_path = Rails.root.join("./spec/fixtures/files/import_data.txt")
    imported_file = admin.imported_files.build(name: 'Base', data: Rack::Test::UploadedFile.new(file_path, 'text/plain'), total_lines: 3)
    imported_file.update(complete_lines: 0, success_user: 0, success_company_profile: 0, success_job_posting: 0)
    imported_file.save!

    UpdateImportedFileService.call(
      imported_file: imported_file,
      complete_lines: 3,
      success_user: 2,
      success_company_profile: 1,
      success_job_posting: 4
    )

    expect(imported_file.reload.complete_lines).to eq(3)
    expect(imported_file.reload.success_user).to eq(2)
    expect(imported_file.reload.success_company_profile).to eq(1)
    expect(imported_file.reload.success_job_posting).to eq(4)
  end
end
