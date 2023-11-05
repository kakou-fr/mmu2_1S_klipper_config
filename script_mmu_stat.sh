#!/bin/bash
if [ "x$1" == "xRESET" ]
then
	echo -n > /tmp/mmu_stat.log
else
	echo "$(date +%s):$1" >> /tmp/mmu_stat.log
fi
