#!/usr/bin/env bash

# -e: exit when any command fails
# -x: all executed commands are printed to the terminal
# -o pipefail: prevents errors in a pipeline from being masked
set -exo pipefail
env

cd $WORKSPACE_DIR

# mark all generic commands
cat README.md | sed '/^ *```all$/,/^ *```$/ s/^ *\$/_M_/' > parse
# mark platform dependent commands
sed -i '/^ *```.*'"$DOCKER_IMAGE"'.*/,/^ *```$/ s/^ *\$/_M_/' parse
# comment all lines without the marker
sed -i '/^_M_/! s/^/# /' parse
# remove the appended comment from all marked lines
sed -i '/^_M_/ s/<--.*//' parse
# remove the marker
sed -i 's/^_M_ //' parse
# remove sudo, it is not necessary in docker
sed -i 's/sudo //g' parse

cp .ci/script.sh ./
cat parse >> script.sh
echo -e '\nexit 0' >> script.sh

# set up dbus for tpm2-abrmd
apt update
apt install -y dbus
#dbus-run-session -- bash
dbus-run-session -- bash -c ./script.sh

exit 0