## Description
Score viewer of figureskating competitions. you can register/see:

- score and its details (ex. element/component details)
- competitions (only ISU competitions supported)
- skaters info (incl. ISU bio info)


## Install

```sh
% bundle install
% bundle exec rake db:migrate
% bundle exec rake update
% bundle exec padrino start
```

## Deploy to heroku

```sh
% heroku create --app app_name
% heroku addons:add heroku-postgresql
% heroku run rake db:migrate
% heroku config
DATABASE_URL=.....
% DATABSEL_URL=..... rake update
% DATABSEL_URL=..... rake update_skaters
```
### Reset database

```sh
% heroku pg:reset DATABASE --confirm
```

and do migrate so on as ablove.

