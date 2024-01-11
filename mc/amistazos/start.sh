#!/bin/sh

rsync -rvtPu /data/ /server

cd /server

java $(tr '\n' ' ' < user_jvm_args.txt) -jar "forge-1.12.2-14.23.5.2859.jar" nogui
