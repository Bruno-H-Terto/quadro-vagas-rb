class ImportLineReport < ApplicationRecord
  belongs_to :imported_file
  validates :line, :command, :message, presence: true

  enum :status, {
    waiting: 0, success: 5, failed: 10
  }
end
