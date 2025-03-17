require 'rails_helper'

RSpec.describe ImportedFile, type: :model do
  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:data) }
    it { should belong_to(:user) }
    it { should have_many(:import_line_reports) }
  end

  context '#valid?' do
    it 'should accept txt format' do
      admin = create(:user, role: 'admin')
      file = Rails.root.join('./spec/fixtures/files/import_data.txt')
      imported_file = admin.imported_files.build(name: 'Base')
      imported_file.data.attach(io: File.open(file), filename: 'import_data.txt')
      
      expect(imported_file).to be_valid
    end

    it 'should accept csv format' do
      admin = create(:user, role: 'admin')
      file = Rails.root.join('./spec/fixtures/files/import_data.txt')
      imported_file = admin.imported_files.build(name: 'Base')
      imported_file.data.attach(io: File.open(file), filename: 'import_data.csv')
      
      expect(imported_file).to be_valid
    end

    it 'should not accept other types of formats' do
      admin = create(:user, role: 'admin')
      file = Rails.root.join('./spec/fixtures/files/import_data.txt')
      imported_file = admin.imported_files.build(name: 'Base')
      imported_file.data.attach(io: File.open(file), filename: 'import_data.pdf')
      
      expect(imported_file).not_to be_valid
    end
  end

  context '.complete?' do
    it 'should return true if complete lines and total lines are equal' do
      admin = create(:user, role: 'admin')
      file = Rails.root.join('./spec/fixtures/files/import_data.txt')
      imported_file = admin.imported_files.build(name: 'Base', complete_lines: 3, total_lines: 3)
      imported_file.data.attach(io: File.open(file), filename: 'import_data.csv')

      expect(imported_file.complete?).to eq true
    end

    it 'should return false if complete lines and total lines are not equal' do
      admin = create(:user, role: 'admin')
      file = Rails.root.join('./spec/fixtures/files/import_data.txt')
      imported_file = admin.imported_files.build(name: 'Base', complete_lines: 3, total_lines: 0)
      imported_file.data.attach(io: File.open(file), filename: 'import_data.csv')

      expect(imported_file.complete?).to eq false
    end
  end

  context '.reports_failed' do
    it 'should return all import lines report that failed' do
      admin = create(:user, role: 'admin')
      file = Rails.root.join('./spec/fixtures/files/import_data.txt')
      imported_file = admin.imported_files.build(name: 'Base', complete_lines: 3, total_lines: 3)
      imported_file.data.attach(io: File.open(file), filename: 'import_data.csv')
      imported_file.save!
      imported_file.import_line_reports.create(line: 1, command: 'U,usuario1@example.com, , password456, Fulano, da Silva', message: 'Password cannot be blank, Password confirmation does not match Password, and Password is too short (minimum: 6 characters)', status: :failed)
      imported_file.import_line_reports.create(line: 2, command: 'E,,https://www.empresa-a.com,contato@empresa-a.com,', message: 'User is required and Name cannot be blank', status: :failed)
      imported_file.import_line_reports.create(line: 3, command: 'V,Desenvolvedor Ruby on Rails,,brl,monthly,remote,,São Paulo,,,Estamos contratando Dev. Rails Júnior', message: 'Company profile is required, Job type is required, Experience level is required, Salary cannot be blank, and Company profile cannot be blank', status: :failed)

      report_content = imported_file.reports_failed

      expect(report_content).to include("1 - U,usuario1@example.com, , password456, Fulano, da Silva - Password cannot be blank, Password confirmation does not match Password, and Password is too short (minimum: 6 characters)")
      expect(report_content).to include("2 - E,,https://www.empresa-a.com,contato@empresa-a.com, - User is required and Name cannot be blank")
      expect(report_content).to include("3 - V,Desenvolvedor Ruby on Rails,,brl,monthly,remote,,São Paulo,,,Estamos contratando Dev. Rails Júnior - Company profile is required, Job type is required, Experience level is required, Salary cannot be blank, and Company profile cannot be blank")
    end
  end
end
