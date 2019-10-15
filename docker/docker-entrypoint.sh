#!/bin/bash

USER_ID=${LOCAL_USER_ID:-9001}
GROUP_ID=${LOCAL_GROUP_ID:-9001}

if [ ! -d "/home/user" ]; then
  addgroup --gid $GROUP_ID usergrp
  adduser --gecos "" --shell /bin/sh --home /home/user --uid $USER_ID --disabled-password --ingroup usergrp user
fi

export HOME=/home/user

cd /opt/app
exec gosu user "$@"
