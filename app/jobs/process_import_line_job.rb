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
    error = nil
    status = false

    if %w[u e v].include?(type.downcase)
      record_response = NewRecordService.call(type: type, instruction: instruction)
      record = record_response[:object]

      if record
        begin
          status = record.save
        rescue StandardError => e
          error = e.message
        end
      else
        error = record_response[:error] || "Erro desconhecido ao criar o registro."
      end
    else
      error = "Tipo inválido"
    end

    { record: record, status: status, error: error }
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
