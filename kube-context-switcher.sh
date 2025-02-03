#!/bin/bash

switch_context() {
  if [[ ! -f ./contexts.txt ]]; then
    echo "Error: contexts.txt file not found"
    return 1
  fi

  # Read contexts and AWS profiles from the file
  IFS=$'\n' read -d '' -r -a lines < <(awk -F',' '{gsub(/^ +| +$/, "", $1); gsub(/^ +| +$/, "", $2); print $1 "," $2}' contexts.txt)

  if [[ ${#lines[@]} -eq 0 ]]; then
    echo "Error: No contexts found in contexts.txt"
    return 1
  fi

  declare -a contexts
  declare -a profiles

  for line in "${lines[@]}"; do
    IFS=',' read -r context profile <<<"$line"
    contexts+=("$context")
    profiles+=("${profile:-$context}")
  done

  echo "Available contexts (${#contexts[@]} total):"
  for i in "${!contexts[@]}"; do
    echo "[$i] ${contexts[$i]} (AWS Profile: ${profiles[$i]})"
  done

  read -p "Would you like to continue? (y/n) " -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    return 0
  fi

  while true; do
    read -p "Select your desired Kubernetes context (0-$((${#contexts[@]} - 1))) or 'c' to cancel: " CHOICE
    if [[ "$CHOICE" =~ ^[Cc]$ ]]; then
      echo "Operation cancelled"
      return 0
    fi
    if [[ "$CHOICE" =~ ^[0-9]+$ ]] && ((CHOICE < ${#contexts[@]})); then
      break
    fi
    echo "Invalid selection. Please choose a number between 0 and $((${#contexts[@]} - 1)) or 'c' to cancel"
  done

  SELECTED_CONTEXT="${contexts[$CHOICE]}"
  SELECTED_PROFILE="${profiles[$CHOICE]}"

  KUBEDIR="$HOME/.kube-${SELECTED_CONTEXT}/config"

  if [[ ! -f "$KUBEDIR" ]]; then
    echo "Error: Kubernetes config not found at $KUBEDIR"
    return 1
  else
    export KUBECONFIG="$KUBEDIR"
    export AWS_PROFILE="$SELECTED_PROFILE"

    echo "Successfully switched to:"
    echo "- Kubernetes context: $SELECTED_CONTEXT"
    echo "- AWS Profile: $AWS_PROFILE"
    echo "Configuration has been updated in your current session."
  fi
}

switch_context
