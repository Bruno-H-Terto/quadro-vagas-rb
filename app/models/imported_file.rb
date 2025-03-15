class ImportedFile < ApplicationRecord
  belongs_to :user
  has_one_attached :data
  has_many :import_line_reports
end
