----------------------------------------------------------------------
BEFORE ANYTHING
----------------------------------------------------------------------

This list below works fine in ubuntu 16.04 (xenial) and debian 9 
(stretch) although other versions of Ubuntu and Debian may work as well.

The shell script will try to install it when not available in the
ansible admin server.

The ansible playbook and its roles are a kind of skeleton continuously
improving.

The work here is based (and modified) from the git repo:
 - https://github.com/lrgc01/ansible-AWS_dolibarr_drupal.git

----------------------------------------------------------------------
GENERAL STRUCTURE
----------------------------------------------------------------------
Basically an ansible with some external configs to SSH access - check 
\*.sh

The inventories in this approach:
 - frontsrv
 - hasrv
 - dbsrv

There are some playbooks YAML file: 
 - PHPservers.yml
 - HAservers.yml
 - DBservers.yml

 - Folder hierarchy (roles):

   - roles/
   - roles/base
   - roles/common
   - roles/DB_adm
   - roles/finals
   - roles/gitcfg
   - roles/phpcfg
   - roles/python
   - roles/restore
   - roles/SSLcrt
   - roles/users
   - roles/\*/{defaults,tasks,vars,templates,handlers}

 - Other folders:

   - group_vars - from ansible best practices - define vars for 
     each group of servers in an inventory 

   - vars_hosts (not used here) - again from best practices - for specific hostnames

   - vars_files (not used here) - used for specific vars files

   - conf.d - SSH files, keys, certs and other sensitive data

 - Other files:

   - conf.d/testkey - The Company (Orm...) SSH key to copy to ~/.ssh/authorized_keys 
     in order to login into the box.

   - conf.d/ssh_config - SSH client config with hostname and keypath

----------------------------------------------------------------------
BASIC RUNNING (helped by shell scripts)
----------------------------------------------------------------------

Probably the server(s) (lrgc01, lrgc02) is(are) up and running. A first 
run of the playbook might be right to check it, as soon as all tasks
returns "ok".

Just do:

	prompt$ sh site.sh

----------------------------------------------------------------------
EXTRA VARIABLES SUPPLIED (--extra-vars) AND CURRENT CHOICES
----------------------------------------------------------------------

 - gather_y_n: false
   Up to now there is no need
 
 - update_cache_y_n: yes
   The module apt uses this variable. It's off in the script for a 
   while to speed things.

 - purge_y_n: false
   When uninstalling a package we may choose to purge

 - autoremove_y_n: false
   The same as above, we may uninstall the whole dependency tree

----------------------------------------------------------------------
VARIABLES OF MAIN INTEREST IN group_vars or vars_files and so on
----------------------------------------------------------------------

 - www_basedir: if using other than the default /var/www.

 - web_service: if using other package than nginx.

 - remove_list: when removing, if not using nginx nor mysql, should 
   alter here.

 - cert_base_path and key_base_path: change according to your needs.

 - cert_params_hash{C, ST, L, O, OU, etc}: change according to your 
   location.

 - db_list{admuser, admpass, host, user, pass, etc}: change to fit 
   your servers.

----------------------------------------------------------------------
TEMPLATES
----------------------------------------------------------------------

All of them are mandatory to be checked. Templates are very particular 
to one site. They can be found here:

 - roles/base/templates
 - roles/finals/templates

----------------------------------------------------------------------
THE PLAYBOOKs
----------------------------------------------------------------------
Here the output of "ansible-playbook -i frontsrv --list-tasks PHPservers.yml" 
command:

```
playbook: PHPservers.yml

  play #1 (php_servers): php_servers	TAGS: []
    tasks:
      common : Install remote python if not installed ------------	TAGS: [bootstrap_python]
      common : Install requisite packages to run apt_key ---------	TAGS: [apt_keys, update_repository]
      common : Apt keys - add a repository key -------------------	TAGS: [apt_keys, update_repository]
      common : Apt database - add new repo to repository listing -	TAGS: [update_repository]
      common : Update cache and upgrade (may take a time) --------	TAGS: [update_repository]
      common : Install vary basic packages to run ansible --------	TAGS: [install_base_pkg]
      base : Install dependency packages -----------------------	TAGS: [install_dep_pkg]
      base : Ensure directories dir_file_tmpl_list.types=dir ---	TAGS: [config_files, deploy_templates]
      base : Remove undesired files (absent in item.types) -----	TAGS: [config_files, deploy_templates]
      base : Deploy templates dir_file_tmpl_list.types=tmpl ----	TAGS: [config_files, deploy_templates]
      base : Make proper links dir_file_tmpl_list.types=link ---	TAGS: [config_files, deploy_templates]
      base : Upload some files from a list when action=upload --	TAGS: [config_files, copy_files]
      base : Restart service after tmpl/file/link change -------	TAGS: [config_files, copy_files, deploy_templates]
      base : Set some ini type files ---------------------------	TAGS: [config_files]
      base : Download and unarchive a .tgz, .rpm, etc packet ---	TAGS: [config_files]
      base : Configure cron ------------------------------------	TAGS: [cron_config]
      base : Ensure services are started and enabled -----------	TAGS: [install_dep_pkg]
      phpcfg : Composer- require, remove, but no create-project --	TAGS: [php_config]
      phpcfg : Composer create-project using command line --------	TAGS: [php_config]
      users : Create some general purpose users -----------------	TAGS: [base_users]
      users : Retrieve priv key from list of users --------------	TAGS: [auth_keys, base_users]
      users : Fill in authorized_keys to each user of a list ----	TAGS: [auth_keys, base_users]
      gitcfg : Grant repodir permissions to git user -------------	TAGS: [git_config]
      gitcfg : Create some git projects on server ----------------	TAGS: [git_config]
      gitcfg : Clone a remote repo in a separate git dir ---------	TAGS: [git_clone, git_config]
      SSLcrt : Generate private key for account and csr ----------	TAGS: [acme_account, selfsigned_crt, ssl_certificate]
      SSLcrt : Create local CSR certificate ----------------------	TAGS: [selfsigned_crt, ssl_certificate]
      SSLcrt : Create ACME account with respective email ---------	TAGS: [acme_account, ssl_certificate]
      SSLcrt : Generate selfsigned certificate -------------------	TAGS: [selfsigned_crt, ssl_certificate]
      SSLcrt : Create certificate - 1st step challenge -----------	TAGS: [ssl_certificate]
      SSLcrt : Create directory structure for challenge ----------	TAGS: [ssl_certificate]
      SSLcrt : Copy resource to web site to complete the 2nd step	TAGS: [ssl_certificate]
      SSLcrt : Create certificate - 2nd step challenge -get certs-	TAGS: [ssl_certificate]
      SSLcrt : Copy new cert and key to web server's place -------	TAGS: [ssl_certificate]
      SSLcrt : Create (or update) PEM file with CRT and KEY ------	TAGS: [ssl_certificate]
      SSLcrt : Download cert and key files if needed -------------	TAGS: [key_cert_copy_only, ssl_certificate]
      finals : Deploy later specific templates -------------------	TAGS: [final_config]
      finals : Create later directories and set permissions ------	TAGS: [final_config]
      finals : Add or change line in config files ----------------	TAGS: [final_config]
      finals : Restart service after later tmpl/file/link change -	TAGS: [final_config]
```

The output of "ansible-playbook -i hasrv --list-tasks HAservers.yml" 
```
playbook: HAservers.yml

  play #1 (ha_servers): ha_servers      TAGS: []
    tasks:
      common : Install remote python if not installed ------------      TAGS: [bootstrap_python]
      common : Install requisite packages to run apt_key ---------      TAGS: [apt_keys, update_repository]
      common : Apt keys - add a repository key -------------------      TAGS: [apt_keys, update_repository]
      common : Apt database - add new repo to repository listing -      TAGS: [update_repository]
      common : Update cache and upgrade (may take a time) --------      TAGS: [update_repository]
      common : Install vary basic packages to run ansible --------      TAGS: [install_base_pkg]
      base : Install dependency packages -----------------------        TAGS: [install_dep_pkg]
      base : Ensure directories dir_file_tmpl_list.types=dir ---        TAGS: [config_files, deploy_templates]
      base : Remove undesired files (absent in item.types) -----        TAGS: [config_files, deploy_templates]
      base : Deploy templates dir_file_tmpl_list.types=tmpl ----        TAGS: [config_files, deploy_templates]
      base : Make proper links dir_file_tmpl_list.types=link ---        TAGS: [config_files, deploy_templates]
      base : Upload some files from a list when action=upload --        TAGS: [config_files, copy_files]
      base : Restart service after tmpl/file/link change -------        TAGS: [config_files, copy_files, deploy_templates]
      base : Set some ini type files ---------------------------        TAGS: [config_files]
      base : Download and unarchive a .tgz, .rpm, etc packet ---        TAGS: [config_files]
      base : Configure cron ------------------------------------        TAGS: [cron_config]
      base : Ensure services are started and enabled -----------        TAGS: [install_dep_pkg]
      users : Create some general purpose users -----------------       TAGS: [base_users]
      users : Retrieve priv key from list of users --------------       TAGS: [auth_keys, base_users]
      users : Fill in authorized_keys to each user of a list ----       TAGS: [auth_keys, base_users]
      SSLcrt : Generate private key for account and csr ----------      TAGS: [acme_account, selfsigned_crt, ssl_certificate]
      SSLcrt : Create local CSR certificate ----------------------      TAGS: [selfsigned_crt, ssl_certificate]
      SSLcrt : Create ACME account with respective email ---------      TAGS: [acme_account, ssl_certificate]
      SSLcrt : Generate selfsigned certificate -------------------      TAGS: [selfsigned_crt, ssl_certificate]
      SSLcrt : Create certificate - 1st step challenge -----------      TAGS: [ssl_certificate]
      SSLcrt : Create directory structure for challenge ----------      TAGS: [ssl_certificate]
      SSLcrt : Copy resource to web site to complete the 2nd step       TAGS: [ssl_certificate]
      SSLcrt : Create certificate - 2nd step challenge -get certs-      TAGS: [ssl_certificate]
      SSLcrt : Copy new cert and key to web server's place -------      TAGS: [ssl_certificate]
      SSLcrt : Create (or update) PEM file with CRT and KEY ------      TAGS: [ssl_certificate]
      SSLcrt : Download cert and key files if needed -------------      TAGS: [key_cert_copy_only, ssl_certificate]
```

And the output of "ansible-playbook -i dbsrv --list-tasks DBservers.yml" 

```
playbook: DBservers.yml

  play #1 (db_servers): db_servers	TAGS: []
    tasks:
      common : Install remote python if not installed ------------	TAGS: [bootstrap_python]
      common : Install requisite packages to run apt_key ---------	TAGS: [apt_keys, update_repository]
      common : Apt keys - add a repository key -------------------	TAGS: [apt_keys, update_repository]
      common : Apt database - add new repo to repository listing -	TAGS: [update_repository]
      common : Update cache and upgrade (may take a time) --------	TAGS: [update_repository]
      common : Install vary basic packages to run ansible --------	TAGS: [install_base_pkg]
      base : Install dependency packages -----------------------	TAGS: [install_dep_pkg]
      base : Ensure directories dir_file_tmpl_list.types=dir ---	TAGS: [config_files, deploy_templates]
      base : Remove undesired files (absent in item.types) -----	TAGS: [config_files, deploy_templates]
      base : Deploy templates dir_file_tmpl_list.types=tmpl ----	TAGS: [config_files, deploy_templates]
      base : Make proper links dir_file_tmpl_list.types=link ---	TAGS: [config_files, deploy_templates]
      base : Upload some files from a list when action=upload --	TAGS: [config_files, copy_files]
      base : Restart service after tmpl/file/link change -------	TAGS: [config_files, copy_files, deploy_templates]
      base : Set some ini type files ---------------------------	TAGS: [config_files]
      base : Download and unarchive a .tgz, .rpm, etc packet ---	TAGS: [config_files]
      base : Configure cron ------------------------------------	TAGS: [cron_config]
      base : Ensure services are started and enabled -----------	TAGS: [install_dep_pkg]
      users : Create some general purpose users -----------------	TAGS: [base_users]
      users : Retrieve priv key from list of users --------------	TAGS: [auth_keys, base_users]
      users : Fill in authorized_keys to each user of a list ----	TAGS: [auth_keys, base_users]
      DB_adm : Create DBs on respective hosts --------------------	TAGS: [create_databases, databases]
      DB_adm : Grant user privileges in DBs ----------------------	TAGS: [databases, grant_privileges]
      restore : Upload backup files ------------------------------	TAGS: [restore, upload_to_restore]
      restore : Restore file hierarchy (extract backup from archive)	TAGS: [restore, restore_files]
      restore : Restore via shell specific commands ---------------	TAGS: [restore, restore_via_shell]
      finals : Deploy later specific templates -------------------	TAGS: [final_config]
      finals : Create later directories and set permissions ------	TAGS: [final_config]
      finals : Add or change line in config files ----------------	TAGS: [final_config]
      finals : Restart service after later tmpl/file/link change -	TAGS: [final_config]
```

The hiphens o minus signs are used just to make the output easier to 
understand.

Everything is based in few distinct blocks as can be noted in 
roles/\*/tasks folders.

Special attention should be paid to base and SSLcrt role 
in which case have some more included task files like this:

base:

	10-base.yml
	20-specific.yml
	30-cron.yml
	90-last.yml

SSLcrt:

	10-first.yml
	20-challenge.yml
	30-save.yml

This is just to organize. 

----------------------------------------------------------------------
PLAYING WITH THE BOOK
----------------------------------------------------------------------

To run each playbook some extra-vars are needed as summarized above. 
A shell script with some definitions must be adjusted:

This is the expected header in each shell script:

```
BASEDIR="`pwd`"
CONFDIR="${BASEDIR}/conf.d"
SSHCONF="${CONFDIR}/ssh_config"

export BASEDIR CONFDIR SSHCONF

export DISPLAY_SKIPPED_HOSTS="false"

export ANSIBLE_SSH_ARGS="-C -o ControlMaster=auto -o ControlPersist=60s -F ${SSHCONF}"
```

And this is the playbook command itself:

	ansible-playbook --extra-vars "basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" _PLAYBOOK_.yml

As explained above, some other extra-vars may be used, but all have 
their own default values already defined in roles/\*/defaults/main.yml.

It is possible to specify --tags and run just the "git_config" parts:

(after the shell script header!!)
```
$ ansible-playbook \ 
    --extra-vars \
    "basedir=${BASEDIR} confdir=${CONFDIR} sshconf=${SSHCONF}" \
    --tags "git_config" \
    PlaybookName.yml
```

----------------------------------------------------------------------
# Let's Encrypt documentation:
----------------------------------------------------------------------

### Staging environment:

See https://letsencrypt.org/docs/staging-environment/

To avoid warning messages from the browser:

  - Download and install intermediate certificate: https://letsencrypt.org/certs/fakeleintermediatex1.pem

  - Download and install root certificate to trust staging: https://letsencrypt.org/certs/fakelerootx1.pem

