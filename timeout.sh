#!/bin/bash
set -e

values=$(kubectl get pod -n "$CIX_POD_NAMESPACE" "$ARGO_POD_NAME" -ojsonpath='{.metadata.annotations.activeDeadlineSeconds}|{.status.startTime}|{.metadata.annotations.workflows\.argoproj\.io/execution}')
IFS="|" read seconds startTime deadlineJson <<< "${values}"
deadlineTmp=${deadlineJson#*deadline\":\"}
existDeadline=${deadlineTmp%\"*}

cmpDeadline() {
  deadlineTimestamp=$(date -d "${startTime} +${seconds} seconds" +%s)
  existTimestamp=$(date -d "${existDeadline}" +%s)
  test $deadlineTimestamp -lt $existTimestamp
}

if [ -n "$seconds" ]; then
  if [ -z "$existDeadline" ] || cmpDeadline; then
    deadline=$(date -Iseconds -u -d "${startTime} +${seconds} seconds")
	kubectl annotate pod -n "$CIX_POD_NAMESPACE" "$ARGO_POD_NAME" --overwrite workflows.argoproj.io/execution={\"deadline\":\"$deadline\"}
  fi
fi

exec argoexec-bin "$@"

