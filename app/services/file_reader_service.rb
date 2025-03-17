class FileReaderService < ApplicationService
  def call
    run
  end

  private

  def run
    imported_file = kwargs[:imported_file]
    file_data = imported_file.data.download.force_encoding("UTF-8")
    text_data = StringIO.new(file_data)
    total_lines = text_data.read.lines.count
    imported_file.update(total_lines: total_lines)
    text_data.rewind

    text_data
  end
end
