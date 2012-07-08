# coding: utf-8
class Locale
  LOCALES = {
    'en' => 'English (United States)',
    'fr-CA' => 'Français (Canada)',
  }

  class << self
    # @todo Remove once https://github.com/gregbell/active_admin/pull/1470 is merged.
    def available_locales
      LOCALES.keys
    end

    def locale_name(locale)
      LOCALES[locale]
    end
  end
end