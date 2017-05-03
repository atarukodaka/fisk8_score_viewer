## Overview
Score viewer of figureskating competitions. you can register/see:

- score and its details (ex. element/component details)
- competitions (only ISU competitions supported)
- skaters info (incl. ISU bio info)


## Install

### prepare
install postgresql if u dont haveit.

```sh
% sudo yum -y install postgresql-devel
```

pdftotext

```sh
% sudo yum -y install poppler-utils
```

### fisk8viewer

```sh
% bundle install
% bundle exec rake db:migrate
% bundle exec rake update
% bundle exec padrino start
```

## Deploy to heroku

### deploy
```sh
% heroku create --app app_name
% heroku addons:add heroku-postgresql
% heroku run rake db:migrate
% heroku config:get DATABASE_URL
DATABASE_URL=postgres://.....
% DATABASE_URL=postgres://..... RACK_ENV=production rake update
```

### Reset database

```sh
% heroku pg:reset DATABASE --confirm
```

and do migrate so on as ablove.

## Maintain competitions list

Add site url of competitions that you want to add into 'config/competitions.yaml' and run 'rake update'.
