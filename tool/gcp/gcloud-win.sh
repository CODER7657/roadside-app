#!/usr/bin/env bash
# gcloud for Git Bash on Windows: runs gcloud through its bundled Python, because gcloud.cmd breaks
# on arguments with spaces when the SDK is installed under "Cloud SDK".
SDK="$(cygpath "$LOCALAPPDATA")/Google/Cloud SDK/google-cloud-sdk"
exec "$SDK/platform/bundledpython/python.exe" "$SDK/lib/gcloud.py" "$@"
