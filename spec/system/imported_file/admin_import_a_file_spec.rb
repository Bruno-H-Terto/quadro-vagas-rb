require 'rails_helper'

describe 'Admin imports a file', type: :system do
  it 'must be authenticated' do
    visit root_path

    expect(page).not_to have_link 'Importar arquivo'
  end

  it 'must be an admin' do
    user = create(:user, role: 'regular')

    login_as user
    visit root_path

    expect(page).not_to have_link 'Importar arquivo'
  end

  it 'with success' do
    admin = create(:user, role: 'admin')

    login_as admin
    visit root_path
    click_on 'Importar arquivo'
    fill_in 'Nome', with: 'Base de dados 01/01'
    attach_file 'Base', Rails.root.join('spec/fixtures/files/import_data.txt')
    within '#import-form-btn' do
      click_on 'Importar'
    end

    expect(page).to have_content 'Arquivo importado com sucesso!'
    expect(page).to have_content 'Dashboard'
    expect(page).to have_content 'Base de dados 01/01'
    expect(ImportedFile.count).to eq 1
  end

  it 'and sees progress in real time', js: true do
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
      "E,Empresa A,https://www.empresa-a.com,contato@empresa-a.com,#{user.id}",
      "V,Desenvolvedor Ruby on Rails,5000,brl,monthly,remote,#{JobType.first.id},São Paulo,#{ExperienceLevel.first.id},#{company.id},Estamos contratando Dev. Rails Júnior"
    ]

    login_as admin
    visit root_path
    click_on 'Importar arquivo'
    fill_in 'Nome', with: 'Base de dados 01/01'
    attach_file 'Base', Rails.root.join('spec/fixtures/files/import_data.txt')
    within '#import-form-btn' do
      click_on 'Importar'
    end

    expect(page).to have_content 'Carregando...'
    expect(page).not_to have_content 'Instruções realizadas 3 de 3'
    within '#reports' do
      expect(page).not_to have_content 'Relatório'
      expect(page).not_to have_content 'Imprimir relatório'
    end
    sleep 0.2
    expect(ProcessImportedFileJob).to have_received(:perform_later).once
    ProcessImportedFileJob.perform_now(file_id: ImportedFile.last.id)
    ImportedFile.last.update(total_lines: batch.size)
    expect(ProcessImportLineJob).to have_received(:perform_later).at_least(:once)
    ProcessImportLineJob.perform_now(batch: batch, line: 1, imported_file: ImportedFile.last)
    sleep 0.2
    expect(page).not_to have_content 'Carregando...'
    expect(page).to have_content 'Instruções realizadas 3 de 3'
    expect(page).to have_content 'Sucesso: 3'
    expect(page).to have_content 'Falha: 0'
    within '#reports' do
      expect(page).to have_content 'Relatório'
      expect(page).to have_content 'Imprimir relatório'
    end

    new_user = User.last
    expect(new_user.email_address).to eq "usuario1@example.com"
    expect(new_user.name).to eq "Fulano"
    expect(new_user.last_name).to eq "da Silva"

    new_company = CompanyProfile.last
    expect(new_company.name).to eq "Empresa A"
    expect(new_company.website_url).to eq "https://www.empresa-a.com"
    expect(new_company.contact_email).to eq "contato@empresa-a.com"
    expect(new_company.user_id).to eq user.id

    new_job = JobPosting.last
    expect(new_job.title).to eq "Desenvolvedor Ruby on Rails"
    expect(new_job.salary).to eq 5000
    expect(new_job.salary_currency).to eq "brl"
    expect(new_job.salary_period).to eq "monthly"
    expect(new_job.work_arrangement).to eq "remote"
    expect(new_job.job_type_id).to eq JobType.first.id
    expect(new_job.job_type.name).to eq "Full Time"
    expect(new_job.job_location).to eq "São Paulo"
    expect(new_job.experience_level_id).to eq ExperienceLevel.first.id
    expect(new_job.experience_level.name).to eq "Intern"
    expect(new_job.company_profile_id).to eq CompanyProfile.first.id
    expect(new_job.company_profile.name).to eq "BlinkedOn"
    expect(new_job.description.to_plain_text).to eq "Estamos contratando Dev. Rails Júnior"

    ActiveJob::Base.queue_adapter = :test
  end

  it 'fails if mandatory fields are missing' do
    admin = create(:user, role: 'admin')

    login_as admin
    visit root_path
    click_on 'Importar arquivo'
    within '#import-form-btn' do
      click_on 'Importar'
    end

    expect(page).to have_content 'Não foi possível concluir esta operação'
    expect(page).to have_content 'Base não pode ficar em branco'
    expect(page).to have_content 'Nome não pode ficar em branco'
  end

  it 'should accept only .txt or .csv file formats' do
    admin = create(:user, role: 'admin')

    login_as admin
    visit root_path
    click_on 'Importar arquivo'
    fill_in 'Nome', with: 'Base de dados 01/01'
    attach_file 'Base', Rails.root.join('spec/fixtures/files/import_data.pdf')
    within '#import-form-btn' do
      click_on 'Importar'
    end

    expect(page).to have_content 'Não foi possível concluir esta operação'
    expect(page).to have_content 'Base de dados inválida. Formatos permitidos: .txt e .csv'
    expect(ImportedFile.count).to eq 0
  end
end
