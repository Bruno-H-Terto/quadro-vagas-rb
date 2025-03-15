FactoryBot.define do
  factory :import_line_report do
    status { 1 }
    line { 1 }
    command { "MyString" }
    imported_file { nil }
  end
end
