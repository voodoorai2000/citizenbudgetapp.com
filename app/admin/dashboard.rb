# coding: utf-8
ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc{ I18n.t :dashboard }

  controller do
    def index
      @questionnaires = current_admin_user.questionnaires

      # @todo Add fragment caching.
      @charts = {}
      @questionnaires.current.each do |q|
        @charts[q.id.to_s] = {}

        # Make all graphs for a consultation have the same x-axis.
        starts_on = q.starts_on - 3.days
        ends_on = [q.today, q.ends_on].min

        data = []
        hash = q.count_by_date.each_with_object({}) do |row,memo|
          memo[Date.new(row['_id']['year'], row['_id']['month'], row['_id']['day'])] = row['value']['count']
        end
        starts_on.upto(ends_on).each do |date|
          data << %([#{date_to_js(date)}, #{hash[date] || 0}])
        end
        @charts[q.id.to_s][:responses] = {
          count: q.responses.count,
          rows:  data.join(','),
        }

        if q.google_analytics_profile? && q.google_api_authorization.authorized?
          begin
            parameters = {
              'ids'        => q.google_analytics_profile,
              'start-date' => starts_on,
              'end-date'   => ends_on,
            }

            # http://analytics-api-samples.googlecode.com/svn/trunk/src/reporting/javascript/ez-ga-dash/docs/user-documentation.html
            # http://analytics-api-samples.googlecode.com/svn/trunk/src/reporting/javascript/ez-ga-dash/demos/set-demo.html
            data = q.google_api_authorization.reports(parameters.merge({
              'dimensions' => 'ga:date',
              'metrics'    => 'ga:visitors,ga:visits,ga:pageviews',
              'sort'       => 'ga:date',
            }))

            @charts[q.id.to_s][:visits] = {
              name:      Questionnaire.sanitize_domain(data.profileInfo['profileName']),
              property:  data.profileInfo['webPropertyId'],
              visitors:  data.totalsForAllResults['ga:visitors'],
              visits:    data.totalsForAllResults['ga:visits'],
              pageviews: data.totalsForAllResults['ga:pageviews'],
              rows:      data.rows.map{|row|
                %([#{date_to_js(Date.parse(row[0]))}, #{row[1]}, #{row[2]}, #{row[3]}])
              }.join(','),
            }

            data = q.google_api_authorization.reports(parameters.merge({
              'dimensions' => 'ga:source',
              'metrics'    => 'ga:visitors',
              'sort'       => '-ga:visitors',
            }))

            @charts[q.id.to_s][:sources] = {
              rows: data.rows.map{|row|
                %(["#{row[0]}", #{row[1]}])
              }.join(','),
            }
          rescue GoogleApiAuthorization::AccessRevokedError, GoogleApiAuthorization::APIError, SocketError
            # Omit the chart if there's an error.
          end
        end
      end
    end

  protected

    # Google Charts needs a Date object, so we can't use #to_json.
    #
    # @param [Date,Time,DateTime] date a date
    def date_to_js(date)
      # JavaScript months start counting from zero.
      "new Date(#{date.year}, #{date.month - 1}, #{date.day})"
    end
  end

  content title: proc{ I18n.t :dashboard } do
    render 'index'
  end
end
