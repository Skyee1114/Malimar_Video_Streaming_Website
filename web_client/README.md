# Malimar TV web client

## Install
```
bundle install
```

```
cp spec/dummy/.env.example spec/dummy/.env
```

## Run

```
cd spec/dummy
rails s
```

## Clear the cache
Usefull when need to load fresh data or reload failed and cached responses.

```
rake tmp:clear
```

## Clean up template cache
Useful when remove or move templates without updating another templates.

open `app/assets/javascripts/templates.js.erb.slim` and remove all comments (everything, exept the last line)
