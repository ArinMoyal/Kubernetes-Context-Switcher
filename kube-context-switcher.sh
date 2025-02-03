#!/bin/bash

if [[ ! -f ./contexts.txt ]]; then
	echo "Error: contexts.txt file not found"
	return 1
fi

IFS=',' read -ra options <./contexts.txt

echo "Available contexts (${#options[@]} total):"
for i in "${!options[@]}"; do
	options[$i]=$(echo "${options[$i]}" | tr -d ' ')
	echo "[$i] ${options[$i]}"
done

read -p "Would you like to continue? (y/n) " -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Operation cancelled"
	return 0
fi

while true; do
	read -p "Select your desired Kubernetes context (0-$((${#options[@]} - 1)) or 'c' to cancel): " CHOICE
	if [[ "$CHOICE" =~ ^[Cc]$ ]]; then
		echo "Operation cancelled"
		return 0
	fi
	if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -lt "${#options[@]}" ]; then
		break
	fi
	echo "Invalid selection. Please choose a number between 0 and $((${#options[@]} - 1)) or 'c' to cancel"
done

SELECTED_CONTEXT="${options[$CHOICE]}"
KUBEDIR="$HOME/.kube-${SELECTED_CONTEXT}/config"
AWS_CRED="$SELECTED_CONTEXT"

if [[ ! -f "$KUBEDIR" ]]; then
	echo "Error: Kubernetes config not found at $KUBEDIR"
	return 1

else
	export KUBECONFIG=$KUBEDIR
	export AWS_PROFILE=$AWS_CRED

	echo "Successfully switched to:"
	echo "- Kubernetes context: $SELECTED_CONTEXT"
	echo "- AWS Profile: $AWS_PROFILE"
	echo "Configuration has been updated in your current session."

fi
