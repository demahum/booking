class DateRange < ApplicationRecord
  validates :start_date, :end_date, presence: true
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return unless start_date && end_date

    if end_date <= start_date
      errors.add(:end_date, I18n.t('activerecord.errors.models.date_range.attributes.end_date.after_start_date'))
    end
  end
end
