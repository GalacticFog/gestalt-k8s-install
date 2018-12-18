image_pull_success=0

pull_image() {
  docker pull $1 2>&1 | tee output.tmp

  # Note: The following check of '$?' relies on 'set -o pipefail' being set, otherwise an error with 'docker pull' will be shadowed by 
  # 'tee' completing successfully
  if [ $? -ne 0 ]; then

    # Check for known issue:
    cat output.tmp | grep "unauthorized: incorrect username or password" > /dev/null
    if [ $? -eq 0 ]; then
      # It's possibly a known issue: https://github.com/docker/hub-feedback/issues/935
      echo
      echo "  ERROR: It appears that your Docker credentials are incorrect, or you may be logged into Docker"
      echo "  using your email address instead of your Docker ID."
      echo "  (Refer to issue https://github.com/docker/hub-feedback/issues/935)"
      echo
      echo "  Please either 'docker logout' or log into Docker again using your Docker ID, and try again."
      echo
      exit_with_error "Error pulling docker image, installation cannot continue."
    fi

    echo
    echo "Error pulling image '$1', trying one more time..."
    docker pull $1
    if [ $? -ne 0 ]; then
      exit_with_error "Error pulling docker image, installation cannot continue."
    fi
  fi
  rm output.tmp
  echo
}

echo "==========================================="
echo "  Docker CE Pre-Install Configuration"
echo "==========================================="
echo

## Pull docker images

echo

if [ ! -z "$skip_image_pull" ] ; then
  echo "Skipping image pull due to 'skip_image_pull'"
else
  echo "Pulling Gestalt Platform images to local Docker environment..."
  for i in `cat config/install-config.yaml | grep "_IMAGE: " | grep -v '#' | awk '{print $2}'` ; do
    pull_image $i
  done
fi