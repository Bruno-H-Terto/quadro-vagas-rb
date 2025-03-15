class ProcessImportLineJob < ApplicationJob
  queue_as :default

  def perform(batch:, line:, imported_file:)
    reports = []
    batch.each do |command|
      type, instruction = ParseImportCommandService.call(instruction_line: command)
      new_record = run_command(type: type, instruction: instruction)
      reports << report_generate(new_record: new_record,command: command, line: line, imported_file: imported_file)
      line += 1
    end
    ImportLineReport.insert_all!(reports, returning: false)
  end

  private

  def run_command(type:, instruction:)
    generators = {
      u: ->{ new_user(instruction) },
      e: ->{ new_company(instruction) },
      v: ->{ new_job(instruction) }
    }

    
    begin
      record = generators[type.downcase.to_sym]&.call
    rescue
      record = nil
    end
      
    { record: record, status: record&.save }
  end

  def new_user(instructions)
    email_address, password, password_confirmation, name, last_name = instructions
    user = User.new(email_address: email_address,
             password: password,
             password_confirmation: password_confirmation,
             name: name,
             last_name: last_name
             )
  end

  def new_company(instructions)
    name, website_url, contact_email, user_id = instructions
    company_profile = CompanyProfile.new(name: name,
                                         website_url: website_url,
                                         contact_email: contact_email,
                                         user_id: user_id
                                         )
    company_profile.logo.attach(io: File.open(Rails.root.join('spec/support/files/logo.jpg')), filename: 'logo.jpg')
    company_profile
  end

  def new_job(instructions)
    title, salary, salary_currency, salary_period, work_arrangement, job_type_id,
    job_location, experience_level_id, company_profile_id, description = instructions
    JobPosting.new(title: title,
                   salary: salary,
                   salary_currency: salary_currency,
                   salary_period: salary_period,
                   work_arrangement: work_arrangement,
                   experience_level_id: experience_level_id,
                   job_location: job_location,
                   job_type_id: job_type_id,
                   company_profile_id: company_profile_id,
                   description: description
                   )
  end

  def report_generate(new_record:, command:, line:, imported_file:)
    if new_record[:status]
      message = 'Sucesso'
    else
      message = new_record[:record].nil? ? "Tipo inválido" : new_record[:record].errors.full_messages.to_sentence
    end

    {
      imported_file_id: imported_file.id,
      line: line,
      command: command,
      status: new_record[:status] ? :success : :failed,
      message: message
    }
  end
end