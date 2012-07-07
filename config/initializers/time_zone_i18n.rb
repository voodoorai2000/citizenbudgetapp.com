# http://stackoverflow.com/questions/1396623/translating-rails-timezones
class TimeZoneI18n < ActiveSupport::TimeZone
  # activesupport/lib/active_support/values/time_zone.rb
  def to_s
    "(GMT#{formatted_offset}) #{human}"
  end

  def human
    I18n.t(name, :scope => :time_zone, :default => name, :separator => "\001")
  end
end
