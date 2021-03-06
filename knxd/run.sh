#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

INTERFACE=$(jq --raw-output ".interface" $CONFIG_PATH)
DEVICE=$(jq --raw-output ".device" $CONFIG_PATH)
ADDRESS=$(jq --raw-output ".address" $CONFIG_PATH)
CLIENT_ADDRESS=$(jq --raw-output ".client_address" $CONFIG_PATH)
CUSTOM=$(jq --raw-output ".custom_config" $CONFIG_PATH)
USB_FILTERS=$(jq --raw-output ".usb_filters" $CONFIG_PATH)
IF_SECTION=""

if [ ${INTERFACE} = "usb" ]
then
    IF_SECTION="
send-timeout = 3000
filters = $USB_FILTERS"
fi

KNX_INI="
[main]
addr = $ADDRESS
client-addrs = $CLIENT_ADDRESS
connections = server,A.tcp,interface
logfile = /dev/stdout
debug = debug-main

[debug-main]
error-level = 6
trace-mask = 0xffe

[A.tcp]
server = knxd_tcp

[server]
server = ets_router
tunnel = tunnel
router = router
discover = true
name = knxd
debug = debug-server

[debug-server]
error-level = 6
trace-mask = 0xffe

[interface]
driver = $INTERFACE
device = $DEVICE
debug = debug-interface

[debug-interface]
error-level = 6
trace-mask = 0xffe
$IF_SECTION"

if [ ${#CUSTOM} -ge 5 ]
then
    echo "$CUSTOM" >> /etc/knxd.ini
else
    echo "$KNX_INI" >> /etc/knxd.ini
fi

exec knxd /etc/knxd.ini
