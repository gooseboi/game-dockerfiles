#!/bin/sh

rsync -rvtPu /data/ /server

cd /server

java $(tr '\n' ' ' < user_jvm_args.txt) -jar "forge-1.7.10-10.13.4.1614-1.7.10-universal.jar" nogui
