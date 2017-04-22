## Overview
Score viewer of figureskating competitions. you can register/see:

- score and its details (ex. element/component details)
- competitions (only ISU competitions supported)
- skaters info (incl. ISU bio info)


## Install

```sh
% bundle install
% bundle exec rake db:migrate
% bundle exec rake update
% bundle exec rake update_skaters _(optional)_
% bundle exec padrino start
```

## Deploy to heroku

```sh
% heroku create --app app_name
% heroku addons:add heroku-postgresql
% heroku run rake db:migrate
% heroku config:get DATABASE_URL
DATABASE_URL=postgres://.....
% DATABASE_URL=postgres://..... RACK_ENV=production rake update
% DATABASE_URL=postgres://..... RACK_ENV=production rake update_skaters _(optinoal)_
```
### Reset database

```sh
% heroku pg:reset DATABASE --confirm
```

and do migrate so on as ablove.

