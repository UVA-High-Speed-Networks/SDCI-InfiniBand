#!/bin/bash

ibtracert -n $1 $2|egrep '-'|cut -d " " -f 1,3,4|perl -pi -e 's/\[([^\]]*)\] {(0x[a-zA-Z0-9]+)}\[([^\]]*)\]/$1 $2 $3/g'|tr '\n' ','|perl -pi -e 's/\b([0-9]+),([0-9]+)\b/$1 $2,/g'|tr ',' '\n'|egrep -o '\b0x[a-zA-Z0-9]+ [0-9]{1,2} [0-9]{1,2}'
