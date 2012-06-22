## Deployment

Create a new app on Heroku (replace placeholders):

    heroku create -s cedar --addons sendgrid:starter mongolab:starter memcache:5mb newrelic:standard
    heroku config:add AWS_ACCESS_KEY_ID=REPLACE_ME
    heroku config:add AWS_SECRET_ACCESS_KEY=REPLACE_ME
    heroku config:add BITLY_API_KEY=REPLACE_ME
    heroku config:add BITLY_LOGIN=REPLACE_ME
    heroku config:add HEROKU_API_KEY=REPLACE_ME
    heroku config:add HEROKU_APP=REPLACE_ME

If you change any assets, you need to recompile them and add them to Git:

    RAILS_ENV=production bundle exec rake assets:precompile

To copy a development database to production, run (replace placeholders):

    mongodump -h localhost -d citizen_budget_development -o dump-dir
    mongorestore -h MONGOLAB_HOST -d MONGOLAB_DB -u MONGOLAB_USER -p MONGOLAB_PASSWORD dump-dir/*

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

## Troubleshooting

* If you are getting New Relic-related exceptions when starting the Rails server or console, run `gem uninstall psych -a`.
* If saving a record fails with no errors shown, it is likely because an association is invalid.

For minimum uncertainty, use the same version of Ruby (1.9.3-p194) and Bundler (1.2.0.pre) as on Heroku:

    rvm install 1.9.3-p194
    gem install bundler --pre

### Gotchas

* `Mongoid::Paranoia` on embedded documents seems to be buggy. If a deleted embedded document is invalid, it will cause saving the parent to fail.
* Unless you nest an embedded document, you will raise `Access to the collection for COLLECTION is not allowed since it is an embedded document, please access a collection from the root document.`

## Known issues

### iOS

* Adding `touchstart` or `touchend` to `$('html').on('click.dropdown.data-api', clearMenus)` will cause the dropdown to close without jumping to the anchor.
* The navigation bar only switches between fixed and non-fixed when the scroll event is fired, which on iOS devices is after scrolling (the `touchmove` event) ends. Attaching events to `touchmove` doesn't seem to solve the problem.

### IE6

* The app doesn't work in IE6 and sometimes crashes it.
