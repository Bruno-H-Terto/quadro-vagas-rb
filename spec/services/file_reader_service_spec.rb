require 'rails_helper'

RSpec.describe FileReaderService, type: :service do
  describe '#call' do
    it 'returns the file content as a StringIO' do
      file_content = "Linha 1\nLinha 2\nLinha 3\n"
      admin = create(:user, role: 'admin')
      file_path = Rails.root.join("./spec/fixtures/files/import_data.txt")
      imported_file = admin.imported_files.build(name: 'Base', data: Rack::Test::UploadedFile.new(file_path, 'text/plain'))
      imported_file.save!

      allow(imported_file.data).to receive(:download).and_return(file_content)

      result = FileReaderService.call(imported_file: imported_file)

      expect(result).to be_a(StringIO)
      expect(result.read).to eq(file_content)
    end

    it 'updates the total number of lines in imported_file' do
      file_content = "Linha 1\nLinha 2\nLinha 3\n"
      admin = create(:user, role: 'admin')
      file_path = Rails.root.join("./spec/fixtures/files/import_data.txt")
      imported_file = admin.imported_files.build(name: 'Base', data: Rack::Test::UploadedFile.new(file_path, 'text/plain'))
      imported_file.save!

      allow(imported_file.data).to receive(:download).and_return(file_content)

      expect {
        FileReaderService.call(imported_file: imported_file)
      }.to change { imported_file.reload.total_lines }.from(0).to(3)
    end

    it 'forces encoding to UTF-8' do
      file_content = "Linha 1\nLinha 2\nLinha 3\n".encode('ISO-8859-1')
      admin = create(:user, role: 'admin')
      file_path = Rails.root.join("./spec/fixtures/files/import_data.txt")
      imported_file = admin.imported_files.build(name: 'Base', data: Rack::Test::UploadedFile.new(file_path, 'text/plain'))
      imported_file.save!

      allow(imported_file.data).to receive(:download).and_return(file_content)

      result = FileReaderService.call(imported_file: imported_file)

      expect(result.read.encoding.name).to eq('UTF-8')
    end
  end
end
