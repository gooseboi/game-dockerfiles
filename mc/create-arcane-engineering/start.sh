#!/bin/sh

rsync -rvtPu /data/ /server

cd /server
java "@user_jvm_args.txt" "@libraries/net/minecraftforge/forge/1.18.2-40.2.9/unix_args.txt"
