require 'rails_helper'

describe ProcessImportedFileJob, type: :job do
  it 'should be queued when user sends file' do
    file_id = 100
    
    ProcessImportedFileJob.perform_later(file_id: file_id)

    expect(enqueued_jobs.size).to eq(1)
  end

  it 'should queue a job for each line in batches' do
    admin = create(:user, role: 'admin')
    file = Rails.root.join('./spec/fixtures/files/import_data.txt')
    imported_file = admin.imported_files.build(name: 'Relatório Trimestral')
    imported_file.data.attach(io: File.open(file), filename: 'import_data.txt')
    imported_file.save!

    ProcessImportedFileJob.perform_now(file_id: imported_file.id)

    expect(imported_file.reload.total_lines).to eq 105
    expect(enqueued_jobs.size).to eq(2)
    expect(enqueued_jobs.select { |job| job[:job] == ProcessImportLineJob }.size).to eq(2)
  end
end
