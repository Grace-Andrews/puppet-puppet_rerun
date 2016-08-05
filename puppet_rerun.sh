#!/bin/bash
puppetmaster="master.inf.puppet.vm"
puppetagent_rc=1 # Priming a value so the while loop will run the first time
puppetruns=0 # Keep track of how many runs we're doing
failpoint=10 # Fail if number of runs reaches this number

# get status of the last puppet run
get_pupstatus () {
  /bin/curl -sG https://$puppetmaster:8081/pdb/query/v4/nodes/`hostname` \
  --tlsv1 \
  --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem \
  --cert /etc/puppetlabs/puppet/ssl/certs/`hostname`.pem \
  --key /etc/puppetlabs/puppet/ssl/private_keys/`hostname`.pem \
  --data-urlencode 'pretty=true' | awk -F\ :\  '/latest_report_status/ {print $2}' | sed s/\"//g
}

puppetrun_status=$( get_pupstatus )
# Loop through until Puppet run is successful and returns unchanged
while [ "$puppetrun_status" != "unchanged" ]; do
  # Loop through until agent run is successful.
  while [ "$puppetagent_rc" -ne 0 ]; do
    /opt/puppetlabs/puppet/bin/puppet agent -t
    puppetagent_rc=$?
    ((puppetruns++))
    if [ "$puppetruns" -eq "$failpoint" ]; then
      echo "Something is wrong, bailing script"
      exit
    fi
  done
  puppetrun_status=$( get_pupstatus )
done
