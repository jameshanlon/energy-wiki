check_context () {

  # Check the script is run from the directory it lives in.
  if [ ! $(dirname "$0") = "." ]; then
    echo "Run this script from 'scripts/'."
    exit 1
  fi

  # Check the CONFIG file exists.
  if [ ! -f "../CONFIG" ]; then
    echo "'../CONFIG' does not exist."
    exit 1
  fi
}
