require 'rails_helper'

describe 'Admin requests report', type: :request do
  it 'should be successful' do
    admin = create(:user, role: 'admin')
    file_path = Rails.root.join("./spec/fixtures/files/import_data.txt")
    imported_file = admin.imported_files.build(name: 'Base', data: Rack::Test::UploadedFile.new(file_path, 'text/plain'), total_lines: 3)
    imported_file.save!
    batch = [
      "U,usuario1@example.com, Fulano, da Silva",
      "E,,https://www.empresa-a.com,contato@empresa-a.com,",
      "V,Desenvolvedor Ruby on Rails,,brl,monthly,remote,,São Paulo,,,Estamos contratando Dev. Rails Júnior"
    ]
    ProcessImportLineJob.perform_now(batch: batch, line: 1, imported_file: imported_file)

    login_as admin
    get download_report_txt_path, params: { imported_file_id: imported_file.id }

    expect(response.headers['Content-Type']).to eq('text/plain')
    file_content = response.body
    expect(file_content).not_to include("1 - U,usuario1@example.com, Fulano, da Silva")
    expect(file_content).to include("2 - E,,https://www.empresa-a.com,contato@empresa-a.com, - Linha não processada: User ID '' não é um número válido.")
    expect(file_content).to include("3 - V,Desenvolvedor Ruby on Rails,,brl,monthly,remote,,São Paulo,,,Estamos contratando Dev. Rails Júnior - Linha não processada: Job Type ID '' não é um número válido.")
  end

  it 'must be authenticated' do
    admin = create(:user, role: 'admin')
    file_path = Rails.root.join("./spec/fixtures/files/import_data.txt")
    imported_file = admin.imported_files.build(name: 'Base', data: Rack::Test::UploadedFile.new(file_path, 'text/plain'), total_lines: 3)
    imported_file.save!
    batch = [
      "U,usuario1@example.com, , password456, Fulano, da Silva",
      "E,,https://www.empresa-a.com,contato@empresa-a.com,",
      "V,Desenvolvedor Ruby on Rails,,brl,monthly,remote,,São Paulo,,,Estamos contratando Dev. Rails Júnior"
    ]
    ProcessImportLineJob.perform_now(batch: batch, line: 1, imported_file: imported_file)

    get download_report_txt_path, params: { imported_file_id: imported_file.id }

    expect(response).to redirect_to new_session_path
  end

  it 'must be admin' do
    user = create(:user, role: 'regular', email_address: 'user@email.com')
    admin = create(:user, role: 'admin')
    file_path = Rails.root.join("./spec/fixtures/files/import_data.txt")
    imported_file = admin.imported_files.build(name: 'Base', data: Rack::Test::UploadedFile.new(file_path, 'text/plain'), total_lines: 3)
    imported_file.save!
    batch = [
      "U,usuario1@example.com, , password456, Fulano, da Silva",
      "E,,https://www.empresa-a.com,contato@empresa-a.com,",
      "V,Desenvolvedor Ruby on Rails,,brl,monthly,remote,,São Paulo,,,Estamos contratando Dev. Rails Júnior"
    ]
    ProcessImportLineJob.perform_now(batch: batch, line: 1, imported_file: imported_file)

    login_as user
    get download_report_txt_path, params: { imported_file_id: imported_file.id }

    expect(response).to redirect_to root_path
    expect(flash[:alert]).to eq 'Requisição inválida, consulte o administrador do serviço.'
  end

  it 'should complete all jobs' do
    admin = create(:user, role: 'admin')
    file_path = Rails.root.join("./spec/fixtures/files/import_data.txt")
    imported_file = admin.imported_files.build(name: 'Base', data: Rack::Test::UploadedFile.new(file_path, 'text/plain'), total_lines: 3)
    imported_file.save!
    batch = [
      "U,usuario1@example.com, , password456, Fulano, da Silva",
      "E,,https://www.empresa-a.com,contato@empresa-a.com,",
      "V,Desenvolvedor Ruby on Rails,,brl,monthly,remote,,São Paulo,,,Estamos contratando Dev. Rails Júnior"
    ]

    login_as admin
    get download_report_txt_path, params: { imported_file_id: imported_file.id }

    expect(response).to redirect_to imported_file_path(imported_file)
    expect(flash[:alert]).to eq "Relatório indisponível, aguarde seu processamento"
  end
end
