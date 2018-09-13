# When Travis runs this, the DB isn't always built yet.
if Language.table_exists?
  def default_locale
    Language.default.try(:abbreviation) || 'en-GB'
  end

  def available_locales
    LocaleSet.new(
      Language.sorted_by_abbreviation.pluck(:abbreviation).presence || [default_locale]
    )
  end
else
  def default_locale
    Rails.application.config.i18n.available_locales.first
  end

  def available_locales
    LocaleSet.new(Array(Rails.application.config.i18n.available_locales))
  end
end

FastGettext.add_text_domain('app', {
  path: 'config/locale',
  type: :po,
  ignore_fuzzy: true,
  report_warning: false,
})

I18n.available_locales        = available_locales.for(:i18n)
FastGettext.default_available_locales = available_locales.for(:fast_gettext)

FastGettext.default_text_domain       = 'app'

I18n.default_locale        = available_locales.for(:i18n).first
FastGettext.default_locale = available_locales.for(:fast_gettext).first
