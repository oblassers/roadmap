class AfterValidator < ActiveModel::EachValidator

  DEFAULT_MESSAGE = _("must be after %{date}")

  def validate_each(record, attribute, value)
    return if value.nil?
    date = options[:date]
    msg  = options.fetch(:message, DEFAULT_MESSAGE % { date: options[:date] })
    record.errors.add(attribute, msg) if value.to_date < options[:date]
  end
end
