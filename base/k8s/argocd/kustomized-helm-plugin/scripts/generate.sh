#!/bin/sh

# Initialize helm command with basic options
helm_cmd="helm template --release-name $ARGOCD_ENV_HELM_RELEASE_NAME --include-crds ."

# Temporary file to hold the find results
temp_file=$(mktemp)

# Search for files and output to temp file
find . -maxdepth 1 -type f \( -iname '*values.yaml' \) > "$temp_file"

# Read from temp file to construct the helm command
while IFS= read -r file; do
  helm_cmd="$helm_cmd -f \"$file\""
done < "$temp_file"

# Remove the temporary file
rm "$temp_file"

# Execute the helm command and pipe its output to all.yaml
eval "$helm_cmd > all.yaml"

# Followed by kustomize build
kustomize build

echo "Command executed: $helm_cmd > all.yaml && kustomize build"
