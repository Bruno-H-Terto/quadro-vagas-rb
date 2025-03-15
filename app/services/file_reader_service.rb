class FileReaderService < ApplicationService
  def call
    run
  end

  private
  
  def run
    file_path = kwargs[:file]
    file_data = file_path.import_data.download
    file = StringIO.new(file_data)
    file.rewind

    file
  end
end