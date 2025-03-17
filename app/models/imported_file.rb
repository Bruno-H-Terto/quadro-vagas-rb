class ImportedFile < ApplicationRecord
  belongs_to :user
  has_one_attached :data
  has_many :import_line_reports

  validates :name, :data, presence: true

  after_create_commit -> {
    broadcast_append_to "imported_file_#{self.id}", partial: "imported_files/progress"
  }

  before_validation :file_allowed_type, if: :data_attached?

  def complete?
    total_lines != 0 && complete_lines == total_lines
  end

  def reports_failed
    reports_list = self.import_line_reports.failed
    reports_content = ""
    reports_list.sort_by(&:line).each do |report_line|
      reports_content << "#{report_line.line} - #{report_line.command.chomp} - #{report_line.message}\n"
    end

    reports_content.strip
  end

  private

  def file_allowed_type
    allowed_types = [ "text/plain", "text/csv" ].freeze
    unless self.data.content_type.in?(allowed_types)
      errors.add(:data, I18n.t("errors.messages.invalid_file_format"))
      throw(:abort)
    end
  end

  def data_attached?
    data.attached?
  end
end
