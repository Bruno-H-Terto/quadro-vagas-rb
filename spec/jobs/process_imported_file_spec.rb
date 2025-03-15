require 'rails_helper'

describe ProcessImportedFileJob, type: :job do
  it 'should be queued when user sends file' do
    file_id = Rails.root.join('spec', 'fixtures', 'files', 'import_data.txt').to_s

    ProcessImportedFileJob.perform_later(file_id: file_id)

    expect(enqueued_jobs.size).to eq(1)
  end

  it 'return nil if file no exists' do
    allow(ImportedFile).to receive(:find_by).and_return(nil)
    
    ProcessImportedFileJob.perform_later(file_id: 99999)

    perform_enqueued_jobs { described_class.perform_later(file_id: 99999) }
  end
end