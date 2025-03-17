class UpdateImportedFileService < ApplicationService
  def call
    run
  end

  private

  def run
    imported_file = kwargs[:imported_file]
    imported_file.increment!(:complete_lines, kwargs[:complete_lines])
    imported_file.increment!(:success_user, kwargs[:success_user])
    imported_file.increment!(:success_company_profile, kwargs[:success_company_profile])
    imported_file.increment!(:success_job_posting, kwargs[:success_job_posting])
  end
end
