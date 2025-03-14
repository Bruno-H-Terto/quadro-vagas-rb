class ProcessImportFileJob < ApplicationJob
  queue_as :default

  def perform(file_id)
    imported_file = ImportedFile.find_by(id: file_id)
    return unless imported_file

    opened_file = OpenFileService.call(imported_file)
    total_lines = opened_file.read.lines.count
    imported_file.update(total_lines: total_lines)

    opened_file.each_with_index do |command_line, index|
      RunLineCommandsJob.perform_later(command: command_line, line: index + 1, imported_file: imported_file)
    end
  end
end