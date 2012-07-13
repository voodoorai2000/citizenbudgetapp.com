## Deployment

Create a new Cedar app on Heroku (replace placeholders):

    heroku create -s cedar --addons sendgrid:starter mongolab:starter memcache:5mb newrelic:standard
    heroku config:add SECRET_TOKEN=`bundle exec rake secret`
    heroku config:add AWS_ACCESS_KEY_ID=REPLACE_ME
    heroku config:add AWS_SECRET_ACCESS_KEY=REPLACE_ME
    heroku config:add AWS_DIRECTORY=REPLACE_ME
    heroku config:add BITLY_API_KEY=REPLACE_ME
    heroku config:add BITLY_LOGIN=REPLACE_ME
    heroku config:add GOOGLE_API_KEY=REPLACE_ME
    heroku config:add GOOGLE_CLIENT_ID=REPLACE_ME
    heroku config:add GOOGLE_CLIENT_SECRET=REPLACE_ME
    heroku config:add GOOGLE_REDIRECT_URI=REPLACE_ME
    heroku config:add HEROKU_API_KEY=REPLACE_ME
    heroku config:add HEROKU_APP=REPLACE_ME

This app by default uses SendGrid to send emails, MongoLab for its database, Memcache for caching, and New Relic for monitoring. We recommend that you set up alerting and [availability monitoring](https://newrelic.com/docs/features/availability-monitoring-faq) in New Relic.

To improve email deliverability, add an SPF record to your domain. Simply create a TXT DNS record with the value `v=spf1 a mx include:sendgrid.net ~all`. If you already have an SPF record, add `include:sendgrid.net` to it.

To get the these constants' values and enable related functionality, follow the following links:
* In production, this app stores uploads on [Amazon S3](http://aws.amazon.com/s3/). Sign up to get your access and secret keys. `AWS_DIRECTORY` is your bucket name.
* [Bitly](http://bitly.com/a/your_api_key/) shortens URLs to make it easier for consultation participants to share links to their responses. Sign up to get an API key and login.
* [Google Analytics](https://developers.google.com/analytics/resources/tutorials/hello-analytics-api#register_project) displays charts and tables about visitors to the consultation website on the administrative dashboard. Follow the instructions to get your API key, client ID and client secret. Remember to give appropriate values for redirect URIs for local development, e.g. `http://localhost:3000/oauth2callback`. Raw IP addresses like `0.0.0.0` are not allowed.
* Automatically configure [Heroku](https://api.heroku.com/account) to serve a consultation's custom domain. Go to your Heroku account page to get your API key. `HEROKU_APP` is the name of your Heroku app (the part before `.herokuapp.com`).

To copy a development database to production, run (replace placeholders):

    mongodump -h localhost -d citizen_budget_development -o dump-dir
    mongorestore -h MONGOLAB_HOST -d MONGOLAB_DB -u MONGOLAB_USER -p MONGOLAB_PASSWORD dump-dir/*

## Configuration

You may want to change some translations in the `config/locales` files, such as `app`, `site_title`, `layouts.application` and `responses.footer`.  There are multiple references to `citizenbudget.com` in the code which you may need to replace (we are working to remove these).

## Development

    cp config/initializers/_heroku.rb.example config/initializers/_heroku.rb

Fill in the values with your own. Run `heroku config` to get the values for `AIRBRAKE_API_KEY` and `MONGOLAB_URI`.

To run a production environment locally:

    export PORT=9000
    export RACK_ENV=production
    foreman start

If you want New Relic to work properly in this enviroment, you must also define (replace placeholders):

    export NEW_RELIC_APP_NAME=REPLACE_ME
    export NEW_RELIC_LICENSE_KEY=REPLACE_ME

Run `heroku config` to get the values for `NEW_RELIC_APP_NAME` and `NEW_RELIC_LICENSE_KEY`. The `newrelic_rpm` gem will load and the `config/newrelic.yml` file will be read before the `_heroku.rb` initializer is run, so defining these environment variables in `_heroku.rb` will have no effect.

To copy a production database to development, run (replace placeholders):

    mongodump -h MONGOLAB_HOST -d MONGOLAB_DB -u MONGOLAB_USER -p MONGOLAB_PASSWORD -o dump-dir
    rm -f dump-dir/MONGOLAB_DB/system.*
    mongorestore -h localhost -d citizen_budget_development --drop dump-dir/*

If you change any assets, you need to recompile them and add them to Git:

    RAILS_ENV=production bundle exec rake assets:precompile
    git add public/assets
    git commit -a -m 'precompile assets'

Rails will cache the assets for some time. To expire all the assets, change the value of `config.assets.version` in `config/application.rb` before precompiling.

## Contributing

If you contribute translations, remember to add a new key-value pair to the `LOCALES` constants in `app/models/locale.rb`.

## Troubleshooting

* For whatever reason, Active Admin caches `ApplicationController` instance methods in development, requiring a restart to invalidate the cache.
* If you are getting New Relic-related exceptions when starting the Rails server or console, run `gem uninstall psych -a`.
* If saving a record fails with no errors shown, it is likely because an association is invalid.

For minimum uncertainty, use the same version of Ruby (1.9.3-p194) and Bundler (1.2.0.pre) as on Heroku:

    rvm install 1.9.3-p194
    gem install bundler --pre

### Gotchas

* `Mongoid::Paranoia` on embedded documents seems to be buggy. If a deleted embedded document is invalid, it will cause saving the parent to fail. This occurred before upgrading to Mongoid 3.
* Unless you nest an embedded document, you will raise `Access to the collection for COLLECTION is not allowed since it is an embedded document, please access a collection from the root document.`

## Known issues

### iOS

* Adding `touchstart` or `touchend` to `$('html').on('click.dropdown.data-api', clearMenus)` will cause the dropdown to close without jumping to the anchor.
* The navigation bar only switches between fixed and non-fixed when the scroll event is fired, which on iOS devices is after scrolling (the `touchmove` event) ends. Attaching events to `touchmove` doesn't seem to solve the problem.

### IE6

* The app doesn't work in IE6 and sometimes crashes it.
