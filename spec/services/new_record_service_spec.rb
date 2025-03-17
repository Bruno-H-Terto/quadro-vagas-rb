require 'rails_helper'

RSpec.describe NewRecordService, type: :service do
  describe '#call' do
    it 'creates a new user object' do
      user_data = [ "usuario@example.com", "senha123", "senha123", "Fulano", "da Silva" ]

      result = NewRecordService.call(instruction: user_data, type: 'u')

      expect(result).to be_a(User)
      expect(result.email_address).to eq("usuario@example.com")
      expect(result.password).to eq("senha123")
      expect(result.password_confirmation).to eq("senha123")
      expect(result.name).to eq("Fulano")
      expect(result.last_name).to eq("da Silva")
    end

    it 'creates a new company profile object' do
      user = create(:user)
      company_data = [ "Empresa X", "https://www.empresa-x.com", "contato@empresa-x.com", user.id ]

      result = NewRecordService.call(instruction: company_data, type: 'e')

      expect(result).to be_a(CompanyProfile)
      expect(result.name).to eq("Empresa X")
      expect(result.website_url).to eq("https://www.empresa-x.com")
      expect(result.contact_email).to eq("contato@empresa-x.com")
      expect(result.user_id).to eq(user.id)
      expect(result.logo).to be_attached
    end

    it 'creates a new job posting object' do
      company = create(:company_profile)
      job_data = [
        "Desenvolvedor Ruby", "5000", "brl", "monthly", "remote",
        1, "São Paulo", 2, company.id, "Estamos contratando Dev. Ruby"
      ]

      result = NewRecordService.call(instruction: job_data, type: 'v')

      expect(result).to be_a(JobPosting)
      expect(result.title).to eq("Desenvolvedor Ruby")
      expect(result.salary).to eq(5000)
      expect(result.salary_currency).to eq("brl")
      expect(result.salary_period).to eq("monthly")
      expect(result.work_arrangement).to eq("remote")
      expect(result.job_type_id).to eq(1)
      expect(result.job_location).to eq("São Paulo")
      expect(result.experience_level_id).to eq(2)
      expect(result.company_profile_id).to eq(company.id)
      expect(result.description.to_plain_text).to eq("Estamos contratando Dev. Ruby")
    end

    it 'returns nil for an unknown type' do
      invalid_data = [ "Dado inválido" ]

      result = NewRecordService.call(instruction: invalid_data, type: 'x')

      expect(result).to be_nil
    end
  end
end
