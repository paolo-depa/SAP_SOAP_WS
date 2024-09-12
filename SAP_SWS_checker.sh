#!/bin/bash

# This script is used to send a SOAP request using cURL to SAP SOAP Web Service(s) (SWS) through the SAP Unix socket(s).
# It checks if the cURL executable is available, sets the appropriate options for cURL,
# and posts the contents of the PAYLOAD_FILE (payload.xml by default) to the specified Unix socket(s).

# The SAP HANA working sockets are expected to match the regexp /tmp/.sapstream5[SID]13 (see SOCKETS variable).
# The url to be used is http://unix/ while the wsdl file can be found at http://unix/SAPControl.cgi?wsdl

CURL=`which curl`
if [ -z $CURL ]; then
    echo "curl executable not found"
    exit 1
else
    CURL="$CURL -L"
fi

CURL_DEBUG=false
if [ "$CURL_DEBUG" = "true" ]; then
    CURL="$CURL -v"
else
    CURL="$CURL -s"
fi

PAYLOAD_FILE="payload.xml"
if [ ! -f $PAYLOAD_FILE ]; then
    echo "Payload file not found"
    exit 1
else
    CURL="$CURL -d \@$PAYLOAD_FILE --header \"Content-Type: text/xml;charset=UTF-8\""
fi

SOCKETS=`ls /tmp/.sapstream5*13`
if [ -z $SOCKETS ]; then
    echo "-- Socket /tmp/.sapstream5*13 not found"
    exit 1
else
    CURL="$CURL --unix-socket $SOCKETS"
fi

for socket in $SOCKETS; do
    echo "-- Using socket: $socket"
    $CURL http://unix/

done
