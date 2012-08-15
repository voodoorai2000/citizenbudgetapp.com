# Used in:
#   config/initializers/secret_token.rb
ENV['SECRET_TOKEN'] = '0f335277346092f873dd7e15546fcd65fc44b2192def45cbf0a777c54dce9b2bd896b44d5ace1d4e1ddeacee9bb538de30772a55dfb37584dfeaf507c1fa390f'

# The default From: address for both mailers, and the default Reply-to: address
# for the admin mailer.
#
# Used in:
#   app/mailers/admin_mailer.rb
#   app/mailers/notifier.rb
ENV['ACTION_MAILER_FROM'] = 'REPLACE_ME'
ENV['ACTION_MAILER_REPLY_TO'] = 'REPLACE_ME'

# The default host used in mailer views. The public mailer sets the host to the
# questionnaire's domain. The admin mailer sets the host to the localized app
# domain, set in the locale files.
#
# @see http://guides.rubyonrails.org/action_mailer_basics.html#generating-urls-in-action-mailer-views
#
# Used in:
#   config/environments/production.rb
ENV['ACTION_MAILER_HOST'] = 'REPLACE_ME'

# In production, this app stores uploads on Amazon S3. Sign up to get your
# access key ID and secret access key.
#
# @see http://aws.amazon.com/s3/
#
# Used in:
#   config/initializers/carrierwave.rb
ENV['AWS_ACCESS_KEY_ID'] = 'REPLACE_ME'
ENV['AWS_SECRET_ACCESS_KEY'] = 'REPLACE_ME'

# Your bucket name. If your top-level domain is example.com, name your budget
# public.example.com and create a CNAME DNS record to point to the bucket.
#
# @see http://docs.amazonwebservices.com/AmazonS3/latest/dev/VirtualHosting.html#VirtualHostingCustomURLs
#
# Used in:
#   config/initializers/carrierwave.rb
ENV['AWS_DIRECTORY'] = 'REPLACE_ME'

# Uncomment the following lines to integrate Bitly URL shortening.
#
# @see http://bitly.com/a/your_api_key/
#
# Used in:
#   app/models/bitly.rb
# ENV['BITLY_API_KEY'] = 'REPLACE_ME'
# ENV['BITLY_LOGIN'] = 'REPLACE_ME'

# Uncomment the following lines to integrate Google Analytics.
#
# @see https://developers.google.com/analytics/resources/tutorials/hello-analytics-api#register_project
#
# Used in:
#   app/models/google_api_authorization.rb
# ENV['GOOGLE_API_KEY'] = 'REPLACE_ME'
# ENV['GOOGLE_CLIENT_ID'] = 'REPLACE_ME'
# ENV['GOOGLE_CLIENT_SECRET'] = 'REPLACE_ME'
# ENV['GOOGLE_REDIRECT_URI'] = 'http://localhost:3000/oauth2callback'

# Uncomment the following lines to integrate Heroku custom domains.
#
# @see https://api.heroku.com/account
#
# Used in:
#   app/models/heroku_client.rb
# ENV['HEROKU_API_KEY'] = 'REPLACE_ME'
# ENV['HEROKU_APP'] = 'REPLACE_ME'

# Uncomment the following line to log exceptions to Airbrake when running a
# production environment locally. Run "heroku config:get AIRBRAKE_API_KEY" to
# get its value from Heroku.
#
# Heroku sets this in production.
#
# Used in:
#   config/initializers/airbrake.rb
# ENV['AIRBRAKE_API_KEY'] = 'REPLACE_ME'

# Required to run a production environment locally.
#
# Heroku sets this in production.
#
# Used in:
#   config/mongoid.yml
ENV['MONGOLAB_URI'] = 'mongodb://127.0.0.1:27017/citizen_budget_development'

# localeapp.com is used as a friendly interface for non-technical users to help
# translate Citizen Budget. Only the project maintainer needs the API key.
#
# @see http://www.localeapp.com/projects/1651
#
# Used in:
#   config/initializers/localeapp.rb
# ENV['LOCALEAPP_API_KEY'] = 'REPLACE_ME'
