require "rails_helper"

describe ProcessImportLineJob, type: :job do
  it "should be queued when user sends intruction line" do
    admin = create(:user, role: "admin")
    imported_file = admin.imported_files.build(name: "Relatório Trimestral")
    imported_file.save!
    batch = [ "U,usuario1@example.com" ]
    line = 1

    ProcessImportedFileJob.perform_later(batch: batch, line: line, imported_file: imported_file)

    expect(enqueued_jobs.size).to eq(1)
  end

  it "should create a user and report success, when received correct instructions" do
    admin = create(:user, role: "admin")
    imported_file = admin.imported_files.build(name: "Relatório Trimestral")
    imported_file.save!
    first_batch = [ "U,usuario1@example.com, password456, password456, Fulano, da Silva" ]

    ProcessImportLineJob.perform_now(batch: first_batch, line: 1, imported_file: imported_file)

    user = User.last
    report_line = ImportLineReport.last
    expect(user.email_address).to eq "usuario1@example.com"
    expect(user.name).to eq "Fulano"
    expect(user.last_name).to eq "da Silva"
    expect(report_line.command).to eq "U,usuario1@example.com, password456, password456, Fulano, da Silva"
    expect(report_line.line).to eq 1
    expect(report_line.success?).to eq true
    expect(report_line.imported_file).to eq imported_file
  end

  it "should create a company profile and report success, when received correct instructions" do
    admin = create(:user, role: "admin")
    user = create(:user, email_address: "test@email.com", id: 2)
    file = Rails.root.join("./spec/fixtures/files/import_data.txt")
    imported_file = admin.imported_files.build(name: "Relatório Trimestral")
    imported_file.data.attach(io: File.open(file), filename: "import_data.txt")
    imported_file.save!
    first_batch = [ "E,Empresa A,https://www.empresa-a.com,contato@empresa-a.com,2" ]

    ProcessImportLineJob.perform_now(batch: first_batch, line: 1, imported_file: imported_file)

    company_profile = CompanyProfile.last
    report_line = ImportLineReport.last
    expect(company_profile.name).to eq "Empresa A"
    expect(company_profile.website_url).to eq "https://www.empresa-a.com"
    expect(company_profile.contact_email).to eq "contato@empresa-a.com"
    expect(company_profile.user_id).to eq 2
    expect(report_line.line).to eq 1
    expect(report_line.success?).to eq true
    expect(report_line.imported_file).to eq imported_file
  end

  it "should create a job posting and report success, when received correct instructions" do
    admin = create(:user, role: "admin")
    user = create(:user, email_address: "test@email.com")
    job_type = create(:job_type, id: 1, name: "Freelance")
    experience_level = create(:experience_level, id: 2, name: "Júnior")
    company_profile = create(:company_profile, id: 1, name: "Ruby LTDA", user: user)
    file = Rails.root.join("./spec/fixtures/files/import_data.txt")
    imported_file = admin.imported_files.build(name: "Relatório Trimestral")
    imported_file.data.attach(io: File.open(file), filename: "import_data.txt")
    imported_file.save!
    first_batch = [ "V,Desenvolvedor Ruby on Rails,5000,brl,monthly,remote,1,São Paulo,2,1, Estamos contratando Dev. Rails Júnior" ]

    ProcessImportLineJob.perform_now(batch: first_batch, line: 1, imported_file: imported_file)

    job_posting = JobPosting.last
    report_line = ImportLineReport.last
    expect(job_posting.title).to eq "Desenvolvedor Ruby on Rails"
    expect(job_posting.salary).to eq 5000
    expect(job_posting.salary_currency).to eq "brl"
    expect(job_posting.salary_period).to eq "monthly"
    expect(job_posting.work_arrangement).to eq "remote"
    expect(job_posting.job_type_id).to eq 1
    expect(job_posting.job_type.name).to eq "Freelance"
    expect(job_posting.job_location).to eq "São Paulo"
    expect(job_posting.experience_level_id).to eq 2
    expect(job_posting.experience_level.name).to eq "Júnior"
    expect(job_posting.company_profile_id).to eq 1
    expect(job_posting.company_profile.name).to eq "Ruby LTDA"
    expect(job_posting.description.to_plain_text).to eq "Estamos contratando Dev. Rails Júnior"
    expect(report_line.line).to eq 1
    expect(report_line.success?).to eq true
    expect(report_line.imported_file).to eq imported_file
  end

  it "should return failed in report" do
        admin = create(:user, role: "admin")
    user = create(:user, email_address: "test@email.com")
    job_type = create(:job_type, id: 1, name: "Freelance")
    experience_level = create(:experience_level, id: 2, name: "Júnior")
    company_profile = create(:company_profile, id: 1, name: "Ruby LTDA", user: user)
    file = Rails.root.join("./spec/fixtures/files/import_data.txt")
    imported_file = admin.imported_files.build(name: "Relatório Trimestral")
    imported_file.data.attach(io: File.open(file), filename: "import_data.txt")
    imported_file.save!
    first_batch = [ 
      "H,usuario2@example.com",
      "U,usuario1.com",
      "E,,https://www.empresa-a.com,contato@empresa-a.com,",
      "V,Desenvolvedor Ruby on Rails,R$ 5000,brl,monthly,,1,São Paulo,,"
    ]

    ProcessImportLineJob.perform_now(batch: first_batch, line: 1, imported_file: imported_file)

    reports = ImportLineReport.all
    expect(reports.count).to eq 4
    expect(reports[0].line).to eq 1
    expect(reports[0].message).to eq "Tipo inválido"
    expect(reports[0].failed?).to eq true
    expect(reports[0].command).to eq "H,usuario2@example.com"
    expect(reports[1].line).to eq 2
    expect(reports[1].message).to eq "Senha não pode ficar em branco, Nome não pode ficar em branco, Sobrenome não pode ficar em branco, Confirmação de Senha não pode ficar em branco, E-mail não é válido e Senha é muito curto (mínimo: 6 caracteres)"
    expect(reports[1].failed?).to eq true
    expect(reports[1].command).to eq "U,usuario1.com"
    expect(reports[2].line).to eq 3
    expect(reports[2].message).to eq "User é obrigatório(a) e Nome não pode ficar em branco"
    expect(reports[2].failed?).to eq true
    expect(reports[2].command).to eq "E,,https://www.empresa-a.com,contato@empresa-a.com,"
    expect(reports[3].line).to eq 4
    expect(reports[3].message).to eq "Company profile é obrigatório(a), Experience level é obrigatório(a), Company profile não pode ficar em branco, Arranjo de trabalho não pode ficar em branco e Descrição não pode ficar em branco"
    expect(reports[3].failed?).to eq true
    expect(reports[3].command).to eq "V,Desenvolvedor Ruby on Rails,R$ 5000,brl,monthly,,1,São Paulo,,"
  end
end