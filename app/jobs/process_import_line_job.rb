class ProcessImportLineJob < ApplicationJob
  queue_as :default

  def perform(command:, line:, imported_file: imported_file)
    type, instruction = ParseImportCommandService.call(command)
    new_record = run_command(type: type, instruction: instruction)
    report_generate(new_record: new_record,command: command, line: line, imported_file: imported_file)
  end

  private

  def run_command(type:, instruction:)
    generators = {
      u: ->{ new_user(instruction) },
      e: ->{ new_company(instruction) },
      v: ->{ new_job(instruction) }
    }

    generators[type.to_sym]&.call
  end

  def new_user(instruction)
    User.new(**instruction)
  end

  def new_company(instruction)
    CompanyProfile.new(**instruction)
  end

  def new_job(instruction)
    JobPosting.new(**instruction)
  end

  def report_generate(new_record, command:, line:, imported_file:)
    report = imported_file.import_line_reports.build(line: line, command: command)
    if new_record&.save
      report.success!
    else
      report.failed!
      new_record.present? ? report.message = new_record.errors.full_messages : report.message = 'Tipe inválido'
    end

    report.save
  end
end