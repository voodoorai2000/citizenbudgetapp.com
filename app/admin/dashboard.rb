# coding: utf-8
ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc{ I18n.t :dashboard }
  controller.before_filter :set_locale # @see https://github.com/gregbell/active_admin/issues/1489

  controller do
    def index
      @charts = {}
      @questionnaires = current_admin_user.questionnaires
      @questionnaires.current.each do |q|
        @charts[q.id.to_s] = {
          # Google Charts needs a Date object, so we can't use #to_json.
          # JavaScript months start counting from zero.
          responses: q.count_by_date.map{
            |row| %([#{date_to_js(row['_id'])}, #{row['value']['count']}])
          }.join(',')
        }
        if q.started? && q.google_analytics_profile? && q.google_api_authorization.authorized?
          begin
            # http://analytics-api-samples.googlecode.com/svn/trunk/src/reporting/javascript/ez-ga-dash/docs/user-documentation.html
            # http://analytics-api-samples.googlecode.com/svn/trunk/src/reporting/javascript/ez-ga-dash/demos/set-demo.html
            data = q.google_api_authorization.reports({
              'ids'        => q.google_analytics_profile,
              'start-date' => q.starts_at - 3.days,
              'end-date'   => [Time.now, q.ends_at].min,
              'metrics'    => 'ga:visitors,ga:visits,ga:pageviews',
              'dimensions' => 'ga:date',
              'sort'       => 'ga:date',
            })
            @charts[q.id.to_s][:visits] = {
              name: Questionnaire.sanitize_domain(data.profileInfo['profileName']),
              property: data.profileInfo['webPropertyId'],
              visitors: data.totalsForAllResults['ga:visitors'],
              visits: data.totalsForAllResults['ga:visits'],
              pageviews: data.totalsForAllResults['ga:pageviews'],
              data: data.rows.map{|row|
                %([#{date_to_js(Date.parse(row[0]))}, #{row[1]}, #{row[2]}, #{row[3]}])
              }.join(','),
            }
          rescue GoogleApiAuthorization::AccessRevokedError, GoogleApiAuthorization::APIError
            # Omit the chart if there's an error.
          end
        end
      end
    end

  protected

    def date_to_js(date)
      if Hash === date
        %(new Date(#{date['year']}, #{date['month'] - 1}, #{date['day']}))
      else # Date, Time or DateTime
        %(new Date(#{date.year}, #{date.month - 1}, #{date.day}))
      end
    end
  end

  content title: proc{ I18n.t :dashboard } do
    render 'index'
  end
end
