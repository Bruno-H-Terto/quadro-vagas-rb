class ParseImportCommandService < ApplicationService
  def call
    run
  end

  private

  def run
    instruction_line = kwargs[:instruction_line].split(",")
    type = instruction_line.shift
    instruction_line = instruction_line.map(&:strip)
    [ type, instruction_line ]
  end
end
