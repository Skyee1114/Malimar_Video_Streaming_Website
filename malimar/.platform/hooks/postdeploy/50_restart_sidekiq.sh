#!/bin/bash

APP_FOLDER=/var/app
APP_ROOT=$APP_FOLDER/current
PIDFILE=$APP_FOLDER/sidekiq.pid

if [ -f $PIDFILE ]
then
  SIDEKIQ_LIVES=$(/bin/ps -o pid= -p `cat $PIDFILE`)
    if [ -z $SIDEKIQ_LIVES ]
    then
      rm -rf $PIDFILE
    else
      kill -TERM `cat $PIDFILE`
      sleep 20
      rm -rf $PIDFILE
    fi
fi

sleep 10

/opt/elasticbeanstalk/.rbenv/shims/bundle exec sidekiq \
  -e production \
  -P $PIDFILE \
  -C $APP_ROOT/config/sidekiq.yml \
  -L $APP_ROOT/log/sidekiq.log \
  -q default \
  -q mailers \
  -q errors \
  -d
