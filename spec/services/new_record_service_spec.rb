require 'rails_helper'

RSpec.describe NewRecordService, type: :service do
  describe '#call' do
    it 'creates a new user object' do
      allow(User).to receive(:generate_random_password).and_return('senha123')
      user_data = [ "usuario@example.com", "Fulano", "da Silva" ]

      result = NewRecordService.call(instruction: user_data, type: 'u')

      expect(result[:object]).to be_a(User)
      expect(result[:object].email_address).to eq("usuario@example.com")
      expect(result[:object].password).to eq("senha123")
      expect(result[:object].password_confirmation).to eq("senha123")
      expect(result[:object].name).to eq("Fulano")
      expect(result[:object].last_name).to eq("da Silva")
      expect(result[:error]).to be_nil
    end

    it 'creates a new company profile object' do
      user = create(:user)
      company_data = [ "Empresa X", "https://www.empresa-x.com", "contato@empresa-x.com", user.id ]

      result = NewRecordService.call(instruction: company_data, type: 'e')

      expect(result[:object]).to be_a(CompanyProfile)
      expect(result[:object].name).to eq("Empresa X")
      expect(result[:object].website_url).to eq("https://www.empresa-x.com")
      expect(result[:object].contact_email).to eq("contato@empresa-x.com")
      expect(result[:object].user_id).to eq(user.id)
      expect(result[:error]).to be_nil
    end

    it 'creates a new job posting object' do
      company = create(:company_profile)
      job_data = [
        "Desenvolvedor Ruby", 5000, "brl", "monthly", "remote",
        1, "São Paulo", 2, company.id, "Estamos contratando Dev. Ruby"
      ]

      result = NewRecordService.call(instruction: job_data, type: 'v')

      expect(result[:object]).to be_a(JobPosting)
      expect(result[:object].title).to eq("Desenvolvedor Ruby")
      expect(result[:object].salary).to eq(5000)
      expect(result[:object].salary_currency).to eq("brl")
      expect(result[:object].salary_period).to eq("monthly")
      expect(result[:object].work_arrangement).to eq("remote")
      expect(result[:object].job_type_id).to eq(1)
      expect(result[:object].job_location).to eq("São Paulo")
      expect(result[:object].experience_level_id).to eq(2)
      expect(result[:object].company_profile_id).to eq(company.id)
      expect(result[:object].description.to_plain_text).to eq("Estamos contratando Dev. Ruby")
      expect(result[:error]).to be_nil
    end

    it 'returns an error for an unknown type' do
      company_data = [ "Empresa X", "https://www.empresa-x.com", "contato@empresa-x.com", 'Invalid' ]

      result = NewRecordService.call(instruction: company_data, type: 'e')

      expect(result[:error]).to eq "User ID 'Invalid' não é um número válido."
      expect(result[:object]).to be_nil
    end
  end
end
