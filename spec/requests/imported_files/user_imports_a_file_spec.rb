require 'rails_helper'

describe 'User imports a file', type: :request do
  it 'with success' do
    admin = create(:user, role: 'admin')
    file_path = Rails.root.join("./spec/fixtures/files/import_data.txt")
    file = Rack::Test::UploadedFile.new(file_path, 'text/plain')

    login_as admin
    post imported_files_path, params: { imported_file: { name: 'Base 10/01', data: file } }

    imported_file = ImportedFile.last
    original_content = File.read(file_path, encoding: 'UTF-8')
    expect(ImportedFile.count).to eq 1
    expect(imported_file.name).to eq 'Base 10/01'
    expect(imported_file.data.filename).to eq file.original_filename
    expect(imported_file.data.download.force_encoding('UTF-8')).to eq original_content
  end

  it 'must be authenticated' do
    file_path = Rails.root.join("./spec/fixtures/files/import_data.txt")
    file = Rack::Test::UploadedFile.new(file_path, 'text/plain')

    post imported_files_path, params: { imported_file: { name: 'Base 10/01', data: file } }

    expect(response).to redirect_to new_session_path
  end

  it 'must be admin' do
    user = create(:user, role: 'regular')
    file_path = Rails.root.join("./spec/fixtures/files/import_data.txt")
    file = Rack::Test::UploadedFile.new(file_path, 'text/plain')

    login_as user
    post imported_files_path, params: { imported_file: { name: 'Base 10/01', data: file } }

    expect(ImportedFile.count).to eq 0
    expect(response).to redirect_to root_path
    expect(flash[:alert]).to eq 'Requisição inválida, consulte o administrador do serviço.'
  end

  it 'should sends a file in txt or csv format' do
    admin = create(:user, role: 'admin')
    file_path = Rails.root.join("./spec/fixtures/files/import_data.pdf")
    file = Rack::Test::UploadedFile.new(file_path, 'application/pdf')

    login_as admin
    post imported_files_path, params: { imported_file: { name: 'Base 10/01', data: file } }

    expect(ImportedFile.count).to eq 0
    expect(flash[:alert]).to eq 'Não foi possível concluir esta operação'
  end
end
