## Configuration

Create a new Cedar app on Heroku. This app by default uses SendGrid to send emails, MongoLab for its database, Memcache for caching, and New Relic for monitoring. We recommend that you set up alerting and [availability monitoring](https://newrelic.com/docs/features/availability-monitoring-faq) in New Relic.

    heroku create -s cedar --addons sendgrid:starter mongolab:starter memcache:5mb newrelic:standard

Then, add basic config vars. You can read [the documentation for each config var](https://github.com/opennorth/citizenbudgetapp.com/blob/master/config/initializers/_heroku.example.rb) in the source.

    heroku config:add SECRET_TOKEN=`bundle exec rake secret`
    heroku config:add ACTION_MAILER_FROM=REPLACE_ME      # noreply@citizenbudget.com
    heroku config:add ACTION_MAILER_HOST=REPLACE_ME      # app.citizenbudget.com
    heroku config:add ACTION_MAILER_REPLY_TO=REPLACE_ME  # info@opennorth.ca

To improve email deliverability, add an SPF record to your domain. Simply create a TXT DNS record with the value `v=spf1 a mx include:sendgrid.net ~all`. If you already have an SPF record, add `include:sendgrid.net` to it.

### File uploads

    heroku config:add AWS_ACCESS_KEY_ID=REPLACE_ME       # AKIAIOSFODNN7EXAMPLE
    heroku config:add AWS_SECRET_ACCESS_KEY=REPLACE_ME   # wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY
    heroku config:add AWS_DIRECTORY=REPLACE_ME           # public.citizenbudget.com

In production, this app stores uploads on Amazon S3. [Sign up](http://aws.amazon.com/s3/) to get your access key ID and secret access key. `AWS_DIRECTORY` is your bucket name. If your top-level domain is `example.com`, name your budget `public.example.com` and [create a CNAME DNS record](http://docs.amazonwebservices.com/AmazonS3/latest/dev/VirtualHosting.html#VirtualHostingCustomURLs) to point to the bucket.

### URL shortening (optional)

    heroku config:add BITLY_API_KEY=REPLACE_ME
    heroku config:add BITLY_LOGIN=REPLACE_ME

Bitly shortens URLs to make it easier for consultation participants to share links to their responses. [Sign up](http://bitly.com/a/your_api_key/) to get an API key and login.

### Web analytics (optional)

    heroku config:add GOOGLE_API_KEY=REPLACE_ME
    heroku config:add GOOGLE_CLIENT_ID=REPLACE_ME
    heroku config:add GOOGLE_CLIENT_SECRET=REPLACE_ME
    heroku config:add GOOGLE_REDIRECT_URI=REPLACE_ME     # http://app.citizenbudget.com/oauth2callback

Google Analytics displays charts and tables about visitors to the consultation website on the administrative dashboard. [Follow the instructions](https://developers.google.com/analytics/resources/tutorials/hello-analytics-api#register_project) to get your API key, client ID and client secret. Remember to give appropriate values for redirect URIs for local development, e.g. `http://localhost:3000/oauth2callback`. Raw IP addresses like `0.0.0.0` are not allowed.

### Custom domains (optional)

    heroku config:add HEROKU_API_KEY=REPLACE_ME
    heroku config:add HEROKU_APP=REPLACE_ME

Automatically configure Heroku to serve a consultation's custom domain. Go to [your Heroku account page](https://api.heroku.com/account) to get your API key. `HEROKU_APP` is the name of your Heroku app (the part before `.herokuapp.com`).

## Customization

You may want to change some translations in the [config/locales](https://github.com/opennorth/citizenbudgetapp.com/tree/master/config/locales) files, such as `app`, `site_title`, `layouts.application`.

## Development

Copy and edit the `_heroku.rb` configuration file:

    cp config/initializers/_heroku.example.rb config/initializers/_heroku.rb

### Database

`bundle exec rake mongodb:pull` will copy a production database to development, and `bundle exec rake mongodb:push` will copy a development database to production.

### Assets

If you change any assets, you need to compile them and add them to Git:

    RAILS_ENV=production bundle exec rake assets:precompile
    git add public/assets
    git commit -a -m 'precompile assets'

### Cache

To expire assets, increment the value of `config.assets.version` in [config/application.rb](https://github.com/opennorth/citizenbudgetapp.com/blob/master/config/application.rb#L63) before compiling.

The following Git pre-commit hook checks for whitespace errors and sets `RAILS_APP_VERSION`, which will cause all ETags to expire on deployment. Paste the code into `.git/hooks/pre-commit` to add this hook.

```sh
#!/bin/sh

# If this is the initial commit, diff against an empty tree object.
if git rev-parse --verify HEAD >/dev/null 2>&1
then
  against=`git rev-parse --short HEAD`
else
  against=4b825dc
fi

# Redirect output to stderr.
exec 1>&2

# Save the Rails app version.
echo "ENV['RAILS_APP_VERSION'] = '$against'" > config/initializers/rails_app_version.rb
git add config/initializers/rails_app_version.rb

# If there are whitespace errors, print the offending file names and fail.
exec git diff-index --check --cached $against --
```

### Production

To run a local production environment that is close to the Heroku environment, run:

    gem install foreman
    export PORT=9000
    export RACK_ENV=production
    foreman start

To get New Relic to work properly in this enviroment, you must also define the following. (Defining these in `_heroku.rb` will have no effect, because the `newrelic_rpm` gem will read `config/newrelic.yml` before any Rails initializers run.)

    export NEW_RELIC_APP_NAME=`heroku config:get NEW_RELIC_APP_NAME`
    export NEW_RELIC_LICENSE_KEY=`heroku config:get NEW_RELIC_LICENSE_KEY`

## Contributing

If you contribute translations, remember to add a new key-value pair to the `LOCALES` constants in `app/models/locale.rb`.

## Troubleshooting

* Active Admin caches `ApplicationController` and `ApplicationHelper` methods in development, requiring a restart.
* If you are getting New Relic-related exceptions when starting the Rails server or console, run `gem uninstall psych -a`.
* If saving a record fails with no explicit errors shown, it is likely because an association is invalid.
* Unless you nest an embedded document, you will raise "Access to the collection for COLLECTION is not allowed since it is an embedded document, please access a collection from the root document."

For minimum uncertainty, use the same version of Ruby (1.9.3-p194) and Bundler (1.2.0.pre) as on Heroku:

    rvm install 1.9.3-p194
    gem install bundler --pre

## Known issues

### iOS

* The navigation bar only switches between fixed and non-fixed when the scroll event is fired, which on iOS devices is after scrolling (the `touchmove` event) ends. Attaching events to `touchmove` doesn't seem to solve the problem.
* Adding `touchstart` or `touchend` to `$('html').on('click.dropdown.data-api', clearMenus)` will cause the dropdown to close without jumping to the anchor.

### IE6

* The app doesn't always work in IE6 and sometimes crashes it.
