#!/usr/bin/python3
# -*- coding: utf-8 -*-

import logging
import psycopg2
import select
import smtplib
import os
import sys
import json
import time
from email.message import EmailMessage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.headerregistry import Address
from email.utils import make_msgid
from email.utils import format_datetime
from email.utils import localtime
from raven import Client

PGHOST = os.environ.get('PGHOST', 'localhost')
LOGLEVEL = os.environ.get('LOGLEVEL', 'INFO')
SENTRY_URL = os.environ.get('SENTRY_URL')
SMTP_HOST = os.environ.get('SMTP_HOST')
SMTP_PORT = os.environ.get('SMTP_PORT', 25)
SMTP_LOGIN = os.environ.get('SMTP_LOGIN')
SMTP_PASSWORD = os.environ.get('SMTP_PASSWORD')

if not SENTRY_URL:
  sys.exit('SENTRY_URL environment variable not specified')

sentryClient = Client(SENTRY_URL)

numeric_level = getattr(logging, LOGLEVEL.upper(), None)
if not isinstance(numeric_level, int):
  raise ValueError('Invalid log level: %s' % loglevel)

logging.basicConfig(format = u'%(filename)s[LINE:%(lineno)d]# %(levelname)-2s [%(asctime)s] %(message)s', level = numeric_level)

####

conn = psycopg2.connect(host=PGHOST)
conn.autocommit = True

cur = conn.cursor()

cur.execute('LISTEN "pgmailer:queued_outmsg"')
smtpconn = None

while 1:
  logging.debug(u'Fetching new outmsg')
  cur.execute('SELECT * FROM pgmailer.sender_take()')
  res = cur.fetchone()
  outmsg = res[0]
  print(outmsg)

  if outmsg:
    outmsg_id = outmsg['id']

    logging.debug(u'Have new outmsg #%s', outmsg_id)

    try:
      if not smtpconn:
        logging.debug(u'Connecting to stmp')
        smtpconn = smtplib.SMTP(SMTP_HOST, SMTP_PORT)
        smtpconn.starttls()
        smtpconn.login(SMTP_LOGIN, SMTP_PASSWORD)

      msg = MIMEMultipart('alternative', _charset='UTF-8')

      msg['Subject'] = outmsg['subject']

      from_addr = Address(display_name=outmsg['from_name'], addr_spec=outmsg['from_email'])
      to_addr = Address(display_name=outmsg['to_name'], addr_spec=outmsg['to_email'])

      msg['From'] = from_addr.__str__()
      msg['To'] = to_addr.__str__()

      if outmsg['body_text']:
        msg.attach(MIMEText(outmsg['body_text'], 'plain'))

      if outmsg['body_html']:
        msg.attach(MIMEText(outmsg['body_html'], 'html'))

      # msg.add_header('Message-Id', make_msgid(domain=from_addr.domain))
      msg.add_header('Date', format_datetime(localtime(), True))

      logging.debug(u'Sending email')

      smtpconn.send_message(msg)

      cur.execute('SELECT pgmailer.sender_complete(%s)', (outmsg_id,))

      logging.debug(u'Outmsg #%s sended', outmsg_id)

    except Exception:
      logging.error(u'%s', sys.exc_info()[1].args[0])
      sentryClient.captureException()
      cur.execute('SELECT pgmailer.sender_error(%s, %s::text)', (outmsg_id, sys.exc_info()[1].args[0]))
      smtpconn = None
      time.sleep(10)

    continue

  if smtpconn:
    smtpconn.quit()
    smtpconn = None

  wait = True
  while wait:
    if select.select([conn],[],[],5) != ([],[],[]):
      while conn.notifies:
        notify = conn.notifies.pop(0)
        logging.debug(u'Getting notification %s', notify.channel)

      wait = False
