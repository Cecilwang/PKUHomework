# !/bin/bash

i=0;
while [ $i -lt $1 ]
do
	echo -n $2 > /sys/bus/usb/drivers/usb/unbind
	echo -n $2 > /sys/bus/usb/drivers/usb/bind
	let i=i+1;
done
