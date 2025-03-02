require 'rails_helper'

describe 'User sees a Job Ad', type: :system do
  it 'with success' do
    visit root_path

    expect(page).to have_content 'Rubi nos trilhos'
    expect(page).to have_content 'Quadro de vagas'
  end

  it 'with Stimulus', js: true do
    visit root_path

    expect(page).to have_css('p', text: 'Carregando...')
    expect(page).to have_css('p', text: 'Hello World com Stimulus', wait: 3)
  end
end