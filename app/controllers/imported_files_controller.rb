class ImportedFilesController < ApplicationController
  def new
    @imported_file = Current.user.imported_files.build
  end

  def create
    @imported_file = Current.user.imported_files.build(imported_file_params)
    if @imported_file.save
      ProcessImportedFileJob.perform_later(file_id: @imported_file.id)
      return redirect_to @imported_file, notice: "Arquivo importado com sucesso"
    end
    render :new
  end

  def show
    @imported_file = ImportedFile.find(params[:id])
  end

  private

  def imported_file_params
    params.require(:imported_file).permit(:name, :data)
  end
end