#!/bin/bash

incard=hw:1
outcard=hw:0

export SC_JACK_DEFAULT_OUTPUTS = "system"
export SC_JACK_DEFAULT_INPUTS = "alsa_in"

jackd -P75 -dalsa -d $outcard -p1024 -n3 &
jack_connect alsa_in:capture_1 SuperCollider:in_1 &
alsa_in -d $incard -c1 -p1024 -n3
