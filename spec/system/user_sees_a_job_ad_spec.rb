require 'rails_helper'

describe 'User sees a Job Ad', type: :system do
  it 'with success' do
    visit root_path

    expect(page).to have_content 'Rubi nos trilhos'
    expect(page).to have_content 'Quadro de vagas'
  end
end