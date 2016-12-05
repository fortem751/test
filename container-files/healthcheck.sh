#!/bin/bash
httptest=$(curl -w %{http_code} -s --output /dev/null localhost:7474)
if [ "netstat -plunt | grep 5001" ]; then
  echo "successfully connected to port 5001"
  if [ "netstat -plunt | grep 6001" ]; then  
    echo "successfully connected to port 6001"
    if [[ $httptest -ne 200 ]]; then
     if [ -f /data/first_run ]; then 
       echo "lost connection to port 7474"
       exit 1 
     else
       echo "still creating a cluster exiting successfully"
       
       exit 0
     fi
    else
     if [ -f /data/first_run ]; then
      echo "connected to port 7474 successfully"
      exit 0 
     else 
      touch /data/first_run
      echo "connected to port 7474 for the first time"
      exit 0
     fi
    fi
  else 
    echo "port 6001 not available exiting"   
    exit 1
  fi
else 
  echo "port 5001 not available exiting"
  exit 1
fi
