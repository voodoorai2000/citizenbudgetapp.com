# coding: utf-8
class Locale
  LOCALES = {
    'en-US' => 'English (United States)',
    'fr-CA' => 'Français (Canada)',
  }

  class << self
    def available_locales
      LOCALES.keys
    end

    def locale_name(locale)
      LOCALES[locale]
    end
  end
end