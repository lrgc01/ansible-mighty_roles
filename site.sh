#!/bin/sh

# Check base packages to continue
which sudo > /dev/null 2>&1
[ "$?" != 0 ] && ( echo "You must install sudo to run this script"; exit 1 )

# Check release
[ -f /etc/os-release ] && . /etc/os-release

which ansible > /dev/null 2>&1
if [ "$?" != 0 ]; then
  case "$ID" in
    'debian')
       grep "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" /etc/apt/sources.list > /dev/null 2>&1 
       if [ "$?" != 0 ]; then
          sudo sh -c "echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' >> /etc/apt/sources.list"
       fi
       # Followed instructions in https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-releases-via-apt-debian
       sudo apt install dirmngr
       sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
       sudo apt-get update
       sudo apt-get -y install ansible
    ;;
    'ubuntu')
       sudo apt-get update
       sudo apt-get -y install software-properties-common
       sudo apt-add-repository ppa:ansible/ansible
       sudo apt-get update
       sudo apt-get -y install ansible
    ;;
    *)
      echo "Sorry, only Debian or Ubuntu by now."
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

export DISPLAY_SKIPPED_HOSTS="false"

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


# First, full, playbook running
ansible-playbook -i frontsrv --extra-vars "gather_y_n=false update_cache_y_n=no basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" PHPservers.yml 
ansible-playbook -i hasrv --extra-vars "gather_y_n=false update_cache_y_n=no basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" HAservers.yml 
ansible-playbook -i dbsrv --extra-vars "gather_y_n=false update_cache_y_n=no basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" DBservers.yml 

# After first install, the tag "bootstrap_python" can be safely skipped:
#ansible-playbook -i frontsrv --extra-vars "gather_y_n=false update_cache_y_n=no basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" --skip-tags "bootstrap_python" PHPservers.yml 
#ansible-playbook -i hasrv --extra-vars "gather_y_n=false update_cache_y_n=no basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" --skip-tags "bootstrap_python" HAservers.yml 
#ansible-playbook -i dbsrv --extra-vars "gather_y_n=false update_cache_y_n=no basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" --skip-tags "bootstrap_python" DBservers.yml 

# garbage
rm -f *.retry
