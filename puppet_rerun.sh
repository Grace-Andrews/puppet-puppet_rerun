#!/bin/bash
puppetrun_status="$(/bin/curl -sG https://master:8081/pdb/query/v4/nodes/`hostname` \
                   --tlsv1 \
                   --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem \
                   --cert /etc/puppetlabs/puppet/ssl/certs/`hostname`.pem \
                   --key /etc/puppetlabs/puppet/ssl/private_keys/`hostname`.pem \
                   --data-urlencode 'pretty=true' | awk -F\ :\  '/latest_report_status/ {print $2}' | sed s/\"//g)"
puppetrun_exitcode=999

# This will run infinitely!  Need to fix.  Find way to capture  exit code
while [ $puppetrun_exitcode -ne 0 ]
do
  if [ PUPPET_RUN!='unchanged' ]
  then
    /opt/puppetlabs/puppet/bin/puppet agent -t
  fi
done
