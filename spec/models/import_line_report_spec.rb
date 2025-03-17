require 'rails_helper'

RSpec.describe ImportLineReport, type: :model do
  context 'validation' do
    it { should validate_presence_of(:line) }
    it { should validate_presence_of(:message) }
    it { should validate_presence_of(:command) }
    it { define_enum_for(:status) }
  end
end
