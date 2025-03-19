class NewRecordService < ApplicationService
  def call
    run
  end

  private

  def run
    instruction = kwargs[:instruction]
    type = kwargs[:type]

    generators = {
      u: -> { new_user(instruction) },
      e: -> { new_company(instruction) },
      v: -> { new_job(instruction) }
    }

    begin
      object = generators[type.downcase.to_sym]&.call
      { object: object, error: nil }
    rescue => error
      { object: nil, error: error.message }
    end
  end

  def new_user(instructions)
    email_address, name, last_name = instructions
    temp_password = User.generate_random_password
    User.new(
      email_address: email_address,
      password: temp_password,
      password_confirmation: temp_password,
      name: name,
      last_name: last_name
    )
  end

  def new_company(instructions)
    name, website_url, contact_email, user_id = instructions
    validate_id!(user_id, "User ID")

    CompanyProfile.new(
      name: name,
      website_url: website_url,
      contact_email: contact_email,
      user_id: user_id.to_i
    )
  end

  def new_job(instructions)
    title, salary, salary_currency, salary_period, work_arrangement,
    job_type_id, job_location, experience_level_id, company_profile_id,
    description = instructions

    validate_id!(job_type_id, "Job Type ID")
    validate_id!(experience_level_id, "Experience Level ID")
    validate_id!(company_profile_id, "Company Profile ID")

    JobPosting.new(
      title: title,
      salary: salary,
      salary_currency: salary_currency,
      salary_period: salary_period,
      work_arrangement: work_arrangement,
      experience_level_id: experience_level_id.to_i,
      job_location: job_location,
      job_type_id: job_type_id.to_i,
      company_profile_id: company_profile_id.to_i,
      description: description
    )
  end

  def validate_id!(id, field_name)
    unless id.to_s.match?(/\A\d+\z/)
      raise ArgumentError, "#{field_name} '#{id}' não é um número válido."
    end
  end
end
