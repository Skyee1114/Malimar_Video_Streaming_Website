#!/bin/bash

APP_FOLDER=/var/app
PIDFILE=$APP_FOLDER/sidekiq.pid

if [ -f $PIDFILE ]
then
  SIDEKIQ_LIVES=$(/bin/ps -o pid= -p `cat $PIDFILE`)
    if [ -z $SIDEKIQ_LIVES ]
    then
      rm -rf $PIDFILE
    else
      kill -USR1 `cat $PIDFILE`
      sleep 10
    fi
fi

