class ProcessImportedFileJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 100

  def perform(file_id:)
    imported_file = ImportedFile.find(file_id)
    opened_file = FileReaderService.call(imported_file: imported_file)

    opened_file.each_slice(BATCH_SIZE).with_index do |batch, index|
      ProcessImportLineJob.perform_later(batch: batch, line: (BATCH_SIZE * index) + 1, imported_file: imported_file)
    end
  end
end
