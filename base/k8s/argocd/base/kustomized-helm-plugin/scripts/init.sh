#!/bin/sh

# Create a temporary directory and check directly
BOBOYSDADDA_TEMP=$(mktemp -d)
if [ -z "$BOBOYSDADDA_TEMP" ]; then
    echo "Failed to create a temporary directory."
    exit 1
fi

# Set environment variables
export XDG_CACHE_HOME="$BOBOYSDADDA_TEMP/cache"
export XDG_CONFIG_HOME="$BOBOYSDADDA_TEMP/config"
export XDG_DATA_HOME="$BOBOYSDADDA_TEMP/data"
export HELM_HOME="$BOBOYSDADDA_TEMP/helm"

# Add helm repository

cd ../../base
if ! helm repo add "$ARGOCD_ENV_HELM_REPO_NAME" "$ARGOCD_ENV_HELM_REPO_URL"; then
    echo "Failed to add helm repository."
    rm -r "$BOBOYSDADDA_TEMP"
    exit 1
fi

# Build helm dependency
if ! helm dependency build; then
    echo "Failed to build helm dependency."
    rm -r "$BOBOYSDADDA_TEMP"
    exit 1
fi

# Cleanup temporary directory
if ! rm -r "$BOBOYSDADDA_TEMP"; then
    echo "Failed to remove the temporary directory."
    exit 1
fi
