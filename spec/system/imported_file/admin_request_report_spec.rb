require 'rails_helper'

describe 'Admin request report', type: :system do
  it 'should be successful', js: true do
    ActiveJob::Base.queue_adapter = :inline
    [ "Full Time", "Part Time", "Freelance" ].each_with_index do |job_type_name, index|
      JobType.create!(name: job_type_name)
    end

    [ "Intern", "Junior", "Mid level", "Senior" ].each_with_index do |experience_level, index|
      ExperienceLevel.create!(name: experience_level)
    end
    company = create(:company_profile)
    admin = User.create!(name: 'Admin', last_name: 'Admin', email_address: 'admin@email.com', password: 'password123', password_confirmation: "password123", role: :admin)
    user = User.create!(name: 'Jhon', last_name: 'Doe', email_address: 'jhon@email.com', password: 'password123', password_confirmation: "password123")
    allow(ProcessImportedFileJob).to receive(:perform_later)
    allow(ProcessImportLineJob).to receive(:perform_later)
    batch = [
      "U,usuario1@example.com, Fulano, da Silva",
      "E,,https://www.empresa-a.com,contato@empresa-a.com,",
      "V,Desenvolvedor Ruby on Rails,,brl,monthly,remote,,São Paulo,,,Estamos contratando Dev. Rails Júnior"
    ]

    login_as admin
    visit root_path
    click_on 'Importar arquivo'
    fill_in 'Nome', with: 'Base de dados 01/01'
    attach_file 'Base', Rails.root.join('spec/fixtures/files/import_data.txt')
    within '#import-form-btn' do
      click_on 'Importar'
    end

    sleep 0.2
    expect(ProcessImportedFileJob).to have_received(:perform_later).once
    ProcessImportedFileJob.perform_now(file_id: ImportedFile.last.id)
    ImportedFile.last.update(total_lines: batch.size)
    expect(ProcessImportLineJob).to have_received(:perform_later).at_least(:once)
    ProcessImportLineJob.perform_now(batch: batch, line: 1, imported_file: ImportedFile.last)
    sleep 0.2
    within '#reports' do
      click_on 'Imprimir relatório'
    end

    tmp_file_path = Rails.root.join('tmp/capybara/Base de dados 01_01-relatório.txt')
    expect(File.exist?(tmp_file_path)).to be_truthy
    file_content = File.read(tmp_file_path)
    expect(file_content).not_to include("1 - U,usuario1@example.com, Fulano, da Silva")
    expect(file_content).to include("2 - E,,https://www.empresa-a.com,contato@empresa-a.com, - Linha não processada: User ID '' não é um número válido.")
    expect(file_content).to include("3 - V,Desenvolvedor Ruby on Rails,,brl,monthly,remote,,São Paulo,,,Estamos contratando Dev. Rails Júnior - Linha não processada: Job Type ID '' não é um número válido.")
    ActiveJob::Base.queue_adapter = :test
  end
end
