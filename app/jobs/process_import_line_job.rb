class ProcessImportLineJob < ApplicationJob
  queue_as :large_import

  def perform(batch:, imported_file:, line:)
    reports = []
    @success_user = 0
    @success_company_profile = 0
    @success_job_posting = 0

    batch.each do |command|
      type, instruction = ParseImportCommandService.call(instruction_line: command)
      new_record = new_record(type: type, instruction: instruction)
      reports << report_generate(new_record: new_record, type: type, command: command, line: line, imported_file: imported_file)
      line += 1
    end

    UpdateImportedFileService.call(imported_file: imported_file,
                                   complete_lines: batch.size,
                                   success_user: @success_user,
                                   success_company_profile: @success_company_profile,
                                   success_job_posting: @success_job_posting)

    ImportLineReport.insert_all!(reports, returning: false)
    broadcast_update(imported_file)
  end

  private

  def new_record(type:, instruction:)
    case type.downcase
    when "u", "e", "v"
      record = NewRecordService.call(type: type, instruction: instruction)
    else
      error = "Tipo inválido"
    end

    begin
      status = record.save if record
    rescue => exception
      status = false
      error = exception
    end

    { record: record, status: status, error: error || nil }
  end

  def report_generate(new_record:, type:, command:, line:, imported_file:)
    if new_record[:status]
      message = "Sucesso"
      incremental_success_type(type: type)
    else
      message = new_record[:record].nil? ? "Linha não processada:" : new_record[:record].errors.full_messages.to_sentence
      message << " #{ new_record[:error] }" if new_record[:error]
    end

    {
      imported_file_id: imported_file.id,
      line: line,
      command: command,
      status: new_record[:status] ? :success : :failed,
      message: message
    }
  end

  def incremental_success_type(type:)
    types = {
              u: -> { @success_user += 1 },
              e: -> { @success_company_profile += 1 },
              v: -> { @success_job_posting += 1 }
            }

    types[type.downcase.to_sym].call
  end

  def broadcast_update(imported_file)
    imported_file.reload
    Turbo::StreamsChannel.broadcast_update_to(
      "imported_file_#{imported_file.id}", target: "imported_file_#{imported_file.id}",
      partial: "imported_files/progress", locals: { imported_file: imported_file }
    )
  end
end
