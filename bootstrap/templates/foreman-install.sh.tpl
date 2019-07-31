#!/bin/bash

# Basic foreman setup, requires working git server with control-repo populated

# See accompanying Confluence article for more information

# Settings you should edit
GIT_SERVER='git@${git_server}'
GIT_NAMESPACE='${git_namespace}'
GIT_REPO_NAME='${git_repo_name}'
CONTROL_REPO="$${GIT_SERVER}:$${GIT_NAMESPACE}/$${GIT_REPO_NAME}"
HOSTNAME="$(hostname -f)"
DOMAINNAME="$(hostname -d)"
ADDITIONAL_DNS_NAMES='${additional_dns_names}'
DNS_ALT_NAMES="puppet.$${DOMAINNAME},puppet,foreman.$${DOMAINNAME},foreman"

# -------------------------------------
# You shouldn't need to edit these
SSH_KEY_FILE='/opt/puppetlabs/server/data/puppetserver/.ssh/id_rsa'
SSH_CONFIG_FILE='/opt/puppetlabs/server/data/puppetserver/.ssh/config'
PUPPET='/opt/puppetlabs/puppet/bin/puppet'
SUDO_PUPPET='sudo -H -u puppet'
REQ_PKGS='epel-release git puppetserver puppet-agent'
MAX_RETRIES=60
RETRY_SLEEP_TIME=60

# Build out DNS_ALT_NAMES if needed
if [[ -n $${ADDITIONAL_DNS_NAMES} ]] ; then
  DNS_ALT_NAMES="$${DNS_ALT_NAMES},$${ADDITIONAL_DNS_NAMES}"
fi

# Install pkgs if not installed
function install_pkgs {
  pkgs=$*
  local install_pkg=''
  for pkg in $REQ_PKGS; do
    rpm -q $pkg || install_pkg="$${install_pkg} $${pkg}"
  done
  [ -z "$install_pkg" ] || yum install -y $${install_pkg}
}

# Retry/Sleep tracking
function retry_sleep {
  if [ $tries -le $MAX_RETRIES ]; then
    echo ""
    echo "Try: $tries / $MAX_RETRIES"
    echo "Sleeping $RETRY_SLEEP_TIME for retry..."
    echo '------------'
    sleep $RETRY_SLEEP_TIME
  else
    echo '----------------------'
    echo '- FAILED INSTALLTION -'
    echo '----------------------'
    echo ""
    echo -e "\n\n\t *** FAILED BOOTSTRAP! \n\t *** SEE: /var/log/cloud-init-output.log\n\n" >> /etc/motd
    exit 1
  fi
}

### MAIN
set +e # exit on error

# Install Stuff
rpm -q puppetlabs-release-pc1 || yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
install_pkgs $REQ_PKGS
# Install latest version of r10k that works with < ruby 2.3 before the first puppet run - doing this here to avoid forking the r10k module
/opt/puppetlabs/puppet/bin/gem install r10k --no-ri --no-rdoc --version 2.6.6
# Install latest version of webrick that works with < ruby 2.3 before the first puppet run - doing this here to avoid forking the r10k module
/opt/puppetlabs/puppet/bin/gem install webrick --no-rdoc --no-ri --version 1.3.1

# Get out of /root (prevents errors while using sudo)
cd /tmp

# Ensure we have an SSH Key
if [ ! -f $SSH_KEY_FILE ]; then
  $SUDO_PUPPET ssh-keygen -t rsa -b 4096 -f $SSH_KEY_FILE -P ""
fi

# Disable SSH strict key host checking for all hosts
cat << EOF > $SSH_CONFIG_FILE
Host *
  StrictHostKeyChecking no

EOF

# Test SSH Access (loop)
if [[ $${GIT_SERVER} =~ 'gitlab' ]]; then
  tries=0
  while true; do
    ((tries++))
    echo "Testing SSH Access to $${GIT_SERVER}..."
    $SUDO_PUPPET /bin/ssh -nTo 'StrictHostKeyChecking=no' $${GIT_SERVER}
    return=$?
    if [ $return == 0 ]; then
      echo "Success!"
      break
    else
      echo -e "\n***********\n"
      echo "There is a problem with the puppet ssh key access to $${GIT_SERVER}"
      echo "You need to add this SSH public key to a 'puppet-server' user in GitLab:"
      echo ""
      cat $${SSH_KEY_FILE}.pub
      retry_sleep
    fi
  done

  # Test Repo Access (loop)
  tries=0
  while true; do
    ((tries++))
    $SUDO_PUPPET git ls-remote $${CONTROL_REPO}
    return=$?
    if [ $return == 0 ]; then
      echo "Success!"
      break
    else
      echo -e "\n***********\n"
      echo "There is a problem with puppet user access to the Git Repo: $${CONTROL_REPO}"
      echo "You need to grant the 'puppet-server' user in GitLab 'reporter' access to the group for the control-repo."
      retry_sleep
    fi
  done
elif [[ $${GIT_SERVER} =~ 'github' ]]; then
  echo "Testing SSH Access to $${GIT_SERVER}..."
  $SUDO_PUPPET /bin/ssh -nTo 'StrictHostKeyChecking=no' $${GIT_SERVER}
  # Test Repo Access (loop)
  tries=0
  while true; do
    ((tries++))
    $SUDO_PUPPET git ls-remote $${CONTROL_REPO}
    return=$?
    if [ $return == 0 ]; then
      echo "Success!"
      break
    else
      echo -e "\n***********\n"
      echo "There is a problem with puppet user access to the Git Repo: $${CONTROL_REPO}"
      echo "You need to grant the 'puppet-server' user in GitLab 'reporter' access to the group for the control-repo."
      cat $${SSH_KEY_FILE}.pub
      retry_sleep
    fi
  done
fi

iptables -F
setenforce 0
iptables -L
getenforce

$PUPPET module list | grep -q r10k || $PUPPET module install puppet-r10k

# Install R10k using puppet
FACTER_gitremote="$${CONTROL_REPO}" $PUPPET apply -e 'class { r10k: remote => "$${::gitremote}"  }'

# This seems dubious, like a packaging error?
chown -hR puppet:puppet /etc/puppetlabs/code

# Deploy (or update) Puppet Code
$SUDO_PUPPET r10k deploy environment -pv

# Helper Alias
grep -q 'alias r10k' /root/.bash_profile || echo "alias r10k='cd /tmp && sudo -H -u puppet r10k'" >> /root/.bash_profile

# Temporarily set this fact directly
mkdir -p /etc/puppetlabs/facter/facts.d
echo "role=foreman" > /etc/puppetlabs/facter/facts.d/role.txt

# Puppet Cert
hostcert=$($PUPPET config print hostcert)
[ -f "$hostcert" ] || $PUPPET cert generate $${HOSTNAME} --dns_alt_names="$${DNS_ALT_NAMES}"

# Seriously hacky business here
# puppetserver.conf:    ruby-load-path: [/opt/puppetlabs/puppet/lib/ruby/vendor_ruby,/etc/puppetlabs/code/environments/production/modules/gms/lib]
PUPPETSERVER_CONF="/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf"
grep -q 'gms/lib' $PUPPETSERVER_CONF || sed -i -r 's#(ruby-load-path:.*)]#\1, /etc/puppetlabs/code/environments/production/modules/gms/lib]#' $PUPPETSERVER_CONF

# Ensure that puppetserver is running
systemctl enable puppetserver
systemctl start puppetserver

# Add missing foreman repo
cat << EOF > /etc/yum.repos.d/foreman-rails.repo
[foreman-rails]
name=Foreman stable
baseurl=http://yum.theforeman.org/rails/latest/el7/\$basearch
enabled=1
gpgcheck=1
gpgkey=https://yum.theforeman.org/rails/latest/RPM-GPG-KEY-foreman

EOF

# Apply foreman profile
$PUPPET apply -e "include profile::foreman" --tags=hiera

# Ensure httpd is running - Puppet will keep httpd running after we are bootstrapped
systemctl enable httpd
systemctl start httpd

$PUPPET agent -t


echo 'DONE!?'
exit 0
