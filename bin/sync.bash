#!/usr/bin/env bash
: <<'!COMMENT'

This script is useful for copying edits in real-time to a remote server, for developing (or deploying.)

!COMMENT

################################################################################
SOURCE="${BASH_SOURCE[0]}" # Dave Dopson, Thank You! - http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	SCRIPTPATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$SCRIPTPATH/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
################################################################################
SCRIPTPATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
SCRIPTNAME=`basename "$SOURCE"`
################################################################################

set -o errexit

# Additional paths
export BASEPATH="$( cd -P "${SCRIPTPATH}/../" && pwd )"
export APPPATH="$( cd -P "${SCRIPTPATH}/../app/" && pwd )"
export DBTPATH="${APPPATH}/.dbt/"

# Parse YAML
source "${SCRIPTPATH}/.support.bash"
eval $( parse_yaml "${DBTPATH}/config.yaml" )

fsSrc="${BASEPATH}/"
fsDest="${sync_user}@${sync_host}:${sync_path}"

shopt -s expand_aliases

echo "Starting constant synchronization." 
alias run_rsync="rsync \
	--progress \
	--partial \
	--archive \
	--verbose \
	--compress \
	--delete \
	--keep-dirlinks \
	--rsh=/usr/bin/ssh \
	\
	--include ".dbt/" \
	--exclude 'sync.bash' \
	--exclude '.*/' \
	--exclude '.*' \
	--exclude 'tmp/' \
	--exclude 'ignore/' \
	\
	${fsSrc} \
	${fsDest}"
 
# Thanks: https://stackoverflow.com/questions/34575374/how-to-use-fswatch-and-rsync-to-automatically-sync-directories
run_rsync; fswatch \
	--print0 \
	--one-per-batch \
	--recursive \
	"${fsSrc}" | while read -d "" event; do run_rsync; done
