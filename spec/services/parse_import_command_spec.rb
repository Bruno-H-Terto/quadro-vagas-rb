require 'rails_helper'

RSpec.describe ParseImportCommandService do
  it 'parses user command correctly' do
    instruction_line = "U, usuario@example.com, Fulano, Silva"
    result = described_class.call(instruction_line: instruction_line)

    expected_type = "U"
    expected_instruction = [ "usuario@example.com", "Fulano", "Silva" ]

    expect(result).to eq([ expected_type, expected_instruction ])
  end

  it 'parses company command correctly' do
    instruction_line = "E, Empresa X, https://empresa.com, contato@empresa.com, 1"
    result = described_class.call(instruction_line: instruction_line)

    expected_type = "E"
    expected_instruction = [ "Empresa X", "https://empresa.com", "contato@empresa.com", "1" ]

    expect(result).to eq([ expected_type, expected_instruction ])
  end

  it 'parses job command correctly' do
    instruction_line = "V, Desenvolvedor Ruby, 5000, brl, monthly, remote, 2, São Paulo, 3, Empresa incrível"
    result = described_class.call(instruction_line: instruction_line)

    expected_type = "V"
    expected_instruction = [
      "Desenvolvedor Ruby", "5000", "brl", "monthly", "remote", "2", "São Paulo", "3", "Empresa incrível"
    ]

    expect(result).to eq([ expected_type, expected_instruction ])
  end

  it 'removes extra spaces in each field' do
    instruction_line = "U,   usuario@example.com ,Fulano  ,  Silva  "
    result = described_class.call(instruction_line: instruction_line)

    expected_type = "U"
    expected_instruction = [ "usuario@example.com", "Fulano", "Silva" ]

    expect(result).to eq([ expected_type, expected_instruction ])
  end
end
