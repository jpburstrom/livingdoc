#!/usr/bin/env python

import sys
from time import sleep
from inputs import get_key, UnpluggedError
from liblo import send

while 1:
    try:
        events = get_key()
        for event in events:
            if event.ev_type == 'Key' and event.state == 1:
                send(57120, "/trig")
        sleep(0.1)
    except UnpluggedError, err:
        print err
        sys.exit(1)










