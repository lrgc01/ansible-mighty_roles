#!/bin/sh

PROGNAME=`basename $0 .sh`

# Check base packages to continue
which sudo > /dev/null 2>&1
[ "$?" != 0 ] && ( echo "You must install sudo to run this script"; exit 1 )

# Check release (get ID from here)
[ -f /etc/os-release ] && . /etc/os-release

which ansible > /dev/null 2>&1
if [ "$?" != 0 ]; then
  which pip > /dev/null 2>&1
  if [ "$?" != 0 ]; then
     case "$ID" in
       'debian'|'ubuntu')
          sudo apt-get install -y python-pip
       ;;
       *)
         echo "Sorry, only Debian or Ubuntu by now."
         exit 
       ;;
     esac
  fi

  case "$ID" in
    'debian'|'ubuntu'|'Centos')
       sudo pip install ansible
    ;;
    *)
      echo "Sorry, only Debian, Ubuntu or Centos by now."
      exit 
    ;;
  esac
fi


PLAYDIR="`dirname $0`"

cd "$PLAYDIR"

BASEDIR="`pwd`"
CONFDIR="${BASEDIR}/conf.d"
SSHCONF="${CONFDIR}/ssh_config"

# Warning: There are particular/private local passwords or keys
# that should be copied (or linked) in $CONFDIR

# Ensure priv keys in conf.d dir are protected
chmod go-w,o-rwx ${CONFDIR}/*

export BASEDIR CONFDIR SSHCONF

export ANSIBLE_DISPLAY_SKIPPED_HOSTS="false"

export ANSIBLE_SSH_ARGS="-C -o ControlMaster=auto -o ControlPersist=60s -F ${SSHCONF}"

# Use --tags "__TAG_NAME__" to restrict ansible-playbook in the following useful tags:
#  - base_users
#  - auth_keys
#  - deploy_templates
#  - cron_config
#  - config_files
#  - ssl_certificate
#  - databases
#  - php_config
#  - drupal_site
#  - final_config
# From common: (these first two must be called when python is missing)
#  - install_dep_pkg
#  - bootstrap_python
#  - update_repository
# To run or not apt update AND apt upgrade
# update_cache_y_n=yes or no

# First, full, playbook running - no skip
SKIP_TAGS=""
# After first install, the tag "bootstrap_python" can be safely skipped:
#SKIP_TAGS="--skip-tags bootstrap_python"

# Order is important, since Docker will create de DBMS server
ansible-playbook -i ${PROGNAME}.inv  --extra-vars "update_cache_y_n=yes basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" $SKIP_TAGS ${PROGNAME}.yml 

# garbage
rm -f *.retry
