class ImportedFilesController < ApplicationController
  before_action :check_user_is_admin
  def new
    @imported_file = Current.user.imported_files.build
  end

  def create
    @imported_file = Current.user.imported_files.build(imported_file_params)
    if @imported_file.save
      ProcessImportedFileJob.perform_later(file_id: @imported_file.id)
      return redirect_to @imported_file, notice: t(".notice")
    end

    flash.now[:alert] = t(".alert")
    render :new, status: :unprocessable_entity
  end

  def show
    @imported_file = ImportedFile.find(params[:id])
  end

  def download
    @imported_file = ImportedFile.find(params[:imported_file_id])
    return redirect_to @imported_file, alert: "Relatório indisponível, aguarde seu processamento" unless @imported_file.complete?
    file_content = @imported_file.reports_failed
    send_data file_content, filename: "#{@imported_file.name}-relatório.txt", type: "text/plain", disposition: "attachment"
  end

  private

  def imported_file_params
    params.require(:imported_file).permit(:name, :data)
  end
end
