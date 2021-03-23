#!/bin/bash

source ~/.bashrc
DAEMON_NAME="logd"
DIR=`dirname "$(realpath "$0")"`
RUN="/usr/bin/php ${DIR}/Run.php logd run" # 프로세스 실행 명령어
STOP="/usr/bin/php ${DIR}/Run.php logd stop" # 프로세스 종료 명령어

RET_VAL=0

check_process() {
	echo "${DAEMON_NAME} shutdown check progress.."
	for i in {1..60}; do
		PID=($(pgrep -f "${RUN}" | grep -v ^$$\$))
		if [[ -z ${PID} ]]; then
			echo "${DAEMON_NAME} shutdown ok"
			RET_VAL=1
			return 1
		fi
		sleep 1
	done
	echo "ERROR: ${$DAEMON_NAME} shutdown failed"
	RET_VAL=$?
}

daemon_start() {
	PID=($(pgrep -f "${RUN}" | grep -v ^$$\$))
	if [[ ! -z ${PID} ]]; then
		echo "${DAEMON_NAME} is already running."
		RET_VAL=1
		return 1
	fi
	${RUN}
	echo "Starting ${DAEMON_NAME}."
	RET_VAL=$?
}

daemon_stop() {
	PID=($(pgrep -f "${RUN}" | grep -v ^$$\$))
	if [[ -z ${PID} ]]; then
		echo "${DAEMON_NAME} is not running."
		RET_VAL=1
		return 1
	fi
	${STOP}
	echo "Shutdown ${DAEMON_NAME}."
	RET_VAL=$?
}

case "$1" in
	start)
		daemon_start
		;;

	stop)
		daemon_stop
		;;

	restart|reload)
		daemon_stop
		check_process
		daemon_start
		RET_VAL=$?
		;;

	status)
		PID=($(pgrep -f "${RUN}" | grep -v ^$$\$))
		if [[ -z ${PID} ]]; then
			echo "${DAEMON_NAME} stopped"
		else
			echo "${DAEMON_NAME} running. PID:" ${PID}
		fi
		;;
	*)
		echo "Usage: $0 {start|stop|restart|status}"
		exit 1
esac

exit ${RET_VAL}
