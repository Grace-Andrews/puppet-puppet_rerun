# This script will run the Puppet agent until we get a successful run with no changes.
$LAST_RUN_REPORT = "C:\ProgramData\PuppetLabs\puppet\cache\state\last_run_report.yaml"
$BINPUPPET = "C:\Program Files\Puppet Labs\Puppet\bin"
$FAILPOINT = 32 # Fail with this number of run failures
$SLEEPTIME = 8 # number of seconds to wait before another run

# get status of the last puppet run
function get_pupstatus {
  if (Test-Path $LAST_RUN_REPORT) {
    ((cat $LAST_RUN_REPORT | Select-String "^status:") -split " +")[1] }
  else {
    write-host "incomplete" 
  }
}

function main {
 $puppet_runs = 0 # Keep track of number of Puppet runs
 $puppet_tries = $FAILPOINT
 $puppetrun_exitcode = 0
 $puppetrun_status = get_pupstatus 

  # Bypass if last Puppet run was successful...
  if ($puppetrun_status -eq "unchanged") {write "Last Puppet run was successful, continuing..."}


  # ... otherwise, loop through until we get a good run or run too many times.
  while ($puppetrun_status -ne "unchanged" ) {
  
    $Puppet_Exists = Test-Path $BINPUPPET
    if ($Puppet_Exists -eq $false) { write "Puppet doesn't appear to have installed correctly.  Exiting script."
      exit 1 }
  

    puppet agent -t > $null
    $puppetrun_exitcode = $LastExitCode 

    if ( $puppetrun_exitcode -eq 1 ) {write "Puppet run failed or run may be in progress. Trying ${puppet_tries} more time(s)."}
    
  
    (($global:puppet_runs++))
    (($global:puppet_tries--))

    if ($puppet_runs -eq $FAILPOINT) {write "Too many Puppet run failures, bailing script.  Could just be an exec resource, or... ?"
      exit 1 }
    

    # Get last run status again.  If we're successful, script is done, otherwise, sleep it off.
    $puppetrun_status = get_pupstatus 
    if ( "$puppetrun_status" -ne "unchanged" ) {
      sleep $SLEEPTIME
    else
      write-host "Puppet run successful."
      exit 0 }
    

  }

}

main 
