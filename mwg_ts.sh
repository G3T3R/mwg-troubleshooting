#!/bin/bash

#############################################
# MWG-Troubleshooting v0.1
#############################################
SCRIPT_VERSION="0.1";

startup () {
	clear;
  echo -e "$(tput setaf 6)$(tput setab 0)$startup_message$(tput sgr 0)\n";
}

startup_message=$(

cat << EOL

*************************************************
*                                               *
*                     +-+-+-+                   *
*                     |M|W|G|                   *
*      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+    *
*      |T|r|o|u|b|l|e|s|h|o|o|t|i|n|g|.|s|h|    *
*      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+    *
*                       v${SCRIPT_VERSION}                    *
*                (March 24rd, 2018)             *
*                                               *
*   This script is created to serve as an aid   *
*   for general MWG troubleshooting such as     *
*   gathering:                                  *
*   - Packet captures.                          *
*   - Creating a Feedback file.                 *
*   - Collecting a core dump.                   *
*                                               *
*************************************************


EOL

)

feedback () {
  echo -e "\nStarting Feedback Script\n"
  sleep 2;
  /opt/mwg/bin/feedback.sh -l 2;
}

tcpdump_open () {
  printf "\nRuning open capture\nEnter Client/User IP: ";
  read client_IP;
  cd /opt/mwg/log/debug/tcpdump;
  tcpdump -s 0 -i any -w open_tcpdump_ClientIP_$client_IP.trace;
  echo -e "\nCapture is in /opt/mwg/log/debug/tcpdump/open_tcpdump_ClientIP_$client_IP.trace\nPlease downloaded from MWG User Interface under Troubleshooting > ApplianceName > Packet Tracing or\nwith WinSCP or similar software. Then uploaded to the Support Portal through https://support.mcafee.com/upload.\n"
}

tcpdump_limited () {
  printf "\nRuning Limited tcpdump by Client IP and Webserver IP\nEnter Client/User IP: ";
	read client_IP;
	printf "\nWas the host having the issue?\nFor example in URL: https://support.mcafee.com/upload/ the host is www.mcafee.com\nEnter the host: ";
	read host;
  echo "";
  cd /opt/mwg/log/debug/tcpdump;
	tcpdump -npi any -s 0 host $client_IP or host $(host $host | grep " has a" | cut -d" " -f4) -w limited_clientip_$client_IP.trace;
  echo -e "\nCapture is in /opt/mwg/log/debug/tcpdump/limited_clientip_$client_IP.trace\nPlease downloaded from MWG User Interface under Troubleshooting > ApplianceName > Packet Tracing or\nwith WinSCP or similar software. Then uploaded to the Support Portal through https://support.mcafee.com/upload.\n"
}
tcpdump_ad () {
  printf "\nAbout to run tcpdump limited to port 53 and 445\n\nEnter Client/User IP: ";
	read client_IP;
  cd /opt/mwg/log/debug/tcpdump;
	tcpdump -npi any -w ad_clientip_$client_IP.trace;
  echo -e "\nCapture is in /opt/mwg/log/debug/tcpdump/ad_clientip_$client_IP.trace\nPlease downloaded from MWG User Interface under Troubleshooting > ApplianceName > Packet Tracing or\nwith WinSCP or similar software. Then uploaded to the Support Portal through https://support.mcafee.com/upload.\n"
}

display_help () {
# Underline
ul=`tput smul`;
# No underline
nul=`tput rmul`;
cat<<MESSAGE

Usage: ${0} [-f|--feedback] [-ot|--opentcpdump] [-lt|--limitedtcpdump] [-at|--adtcpdump] [-d|--processdump][-h|--help]

 -ot|--opentcpdump      Starts an open tcpdump.
 -lt|--limitedtcpdump   Starts a limited tcpdump by Client IP and Web Server Host(IP).
 -at|--adtcpdump        Starts a limited tcpdump by port 53 and 445.
 -d|--processdump       Creates a process dump $(tput setaf 1)(Warning: File can be large depending on the memory usage)$(tput sgr 0).
 -f|--feedback          Creates a Web Gateway Feedback.
 -h|--help              Displays this help.

MESSAGE
exit 0;
}
coredump () {
  cd /opt/mwg/log/debug/cores/;
  printf "Enter the process name you want to dump.\nFor example:\nmwg-core\nmwg-antimalware\nmwg-coordinator\nEnter process name: ";
  read process;
  gcore $(pgrep -n $process -o $process.core);
  echo "Generating MD5";
  md5sum $process.core > $process.core.md5;
  echo "Generated MD5. File containing MD5 sum is $process.core.md5";
  echo -e "\nDump file and MD5 sum is in /opt/mwg/log/debug/cores\nPlease downloaded from MWG User Interface under Troubleshooting > Core Files or\nwith WinSCP or similar software. Then uploaded to the Support Portal through https://support.mcafee.com/upload.\n"
}
startup;
while [ $# -gt 0 ]
do
	case $1 in
    -f|--feedback)		feedback; shift
						;;
    -ot|--opentcpdump)		tcpdump_open; shift
						;;
    -lt|--limitedtcpdump) tcpdump_limited; shift
            ;;
    -at|--adtcpdump) tcpdump_ad; shift
            ;;
    -d|--processdump) coredump; shift
            ;;
		-h|--help)		display_help; break
						;;
		*)          	display_help; break
						;;
	esac
done
