#!/bin/sh
renice -n -5 $(lsof -i :22 | grep "*" | awk '{print $2}')
