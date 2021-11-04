#!/bin/bash
# bootstrap clam av service and clam av database updater shell script
# presented by mko (Markus Kosmal<dude@m-ko.de>)
set -e

# if [[ ! -z "${FRESHCLAM_CONF_FILE}" ]]; then
#     echo "[bootstrap] FRESHCLAM_CONF_FILE set, copy to /etc/clamav/freshclam.conf"
#     mv /etc/clamav/freshclam.conf /etc/clamav/freshclam.conf.bak
#     cp -f ${FRESHCLAM_CONF_FILE} /etc/clamav/freshclam.conf
# fi

# if [[ ! -z "${CLAMD_CONF_FILE}" ]]; then
#     echo "[bootstrap] CLAMD_CONF_FILE set, copy to /etc/clamav/clam.conf"
#     mv /etc/clamav/clamd.conf /etc/clamav/clamd.conf.bak
#     cp -f ${CLAMD_CONF_FILE} /etc/clamav/clamd.conf
# fi
if [[ ! -z "${CVUPDATE_URL}" ]]; then
   echo "PrivateMirror ${CVUPDATE_URL}" >> /etc/clamav/freshclam.conf
fi

# start clam service itself and the updater in background as daemon
# Ensure we have some virus data, otherwise clamd refuses to start
	if [ ! -f "/var/lib/clamav/main.cvd" ]; then
		echo "Updating initial database"
		freshclam --foreground --stdout
	fi

if [ "${CLAMAV_NO_FRESHCLAMD:-false}" != "true" ]; then
		echo "Starting Freshclamd"
		freshclam \
		          --checks="${FRESHCLAM_CHECKS:-4}" \
		          --daemon \
		          --foreground \
		          --stdout \
		          --user="clamav_user" \
			  &
fi
if [ "${CLAMAV_NO_CLAMD:-false}" != "true" ]; then
		echo "Starting ClamAV"
		if [ -S "/var/run/clamav/clamd.socket" ]; then
			unlink "/var/run/clamav/clamd.socket"
		fi
		clamd --foreground &
		while [ ! -S "/var/run/clamav/clamd.socket" ]; do
			if [ "${_timeout:=0}" -gt "${CLAMD_STARTUP_TIMEOUT:=1800}" ]; then
				echo
				echo "Failed to start clamd"
				exit 1
			fi
			printf "\r%s" "Socket for clamd not found yet, retrying (${_timeout}/${CLAMD_STARTUP_TIMEOUT}) ..."
			sleep 1
			_timeout="$((_timeout + 1))"
		done
		echo "socket found, clamd started."
fi
# Wait forever (or until canceled)
exec tail -f "/dev/null"
# recognize PIDs
pidlist=`jobs -p`

# initialize latest result var
latest_exit=0

# define shutdown helper
function shutdown() {
    trap "" SIGINT

    for single in $pidlist; do
        if ! kill -0 $single 2>/dev/null; then
            wait $single
            latest_exit=$?
        fi
    done

    kill $pidlist 2>/dev/null
}

# run shutdown
trap shutdown SIGINT
wait -n

# return received result
exit $latest_exit