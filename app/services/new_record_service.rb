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

    generators[type.downcase.to_sym]&.call
  end

  def new_user(instructions)
    email_address, password, password_confirmation, name, last_name = instructions
    user = User.new(email_address: email_address,
                    password: password,
                    password_confirmation: password_confirmation,
                    name: name,
                    last_name: last_name
                    )

    user
  end

  def new_company(instructions)
    name, website_url, contact_email, user_id = instructions
    company_profile = CompanyProfile.new(name: name,
                                         website_url: website_url,
                                         contact_email: contact_email,
                                         user_id: user_id
                                         )
    company_profile.logo.attach(io: File.open(Rails.root.join("spec/support/files/logo.jpg")), filename: "logo.jpg")

    company_profile
  end

  def new_job(instructions)
    title, salary, salary_currency, salary_period, work_arrangement, job_type_id,
    job_location, experience_level_id, company_profile_id, description = instructions
    job_posting = JobPosting.new(title: title,
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
    job_posting
  end
end
