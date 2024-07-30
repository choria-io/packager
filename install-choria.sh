#!/bin/sh

set -e

FLAVOUR=$(cat /etc/packager.txt)
METHOD="apt"

case "${FLAVOUR?}" in
  el7_64)
    rpm -ivh http://yum.puppetlabs.com/puppet8-release-el-7.noarch.rpm
    METHOD="yum"


    ;;

  el8_64)
    rpm -ivh http://yum.puppetlabs.com/puppet8-release-el-8.noarch.rpm
    METHOD="yum"

    ;;

  el9_64)
    rpm -ivh http://yum.puppetlabs.com/puppet8-release-el-9.noarch.rpm
    METHOD="yum"

    ;;

  buster_64)
    wget -O /tmp/puppet.deb http://apt.puppetlabs.com/puppet8-release-buster.deb

    ;;

  bullseye_64)
    wget -O /tmp/puppet.deb http://apt.puppetlabs.com/puppet8-release-bullseye.deb

    ;;

  bionic_64)
    wget -O /tmp/puppet.deb http://apt.puppetlabs.com/puppet8-release-bionic.deb

    ;;

  focal_64)
    wget -O /tmp/puppet.deb http://apt.puppetlabs.com/puppet8-release-focal.deb

    ;;

  jammy_64)
    wget -O /tmp/puppet.deb http://apt.puppetlabs.com/puppet8-release-jammy.deb

    ;;

  noble_64)
    wget -O /tmp/puppet.deb http://apt.puppetlabs.com/puppet8-release-noble.deb

    ;;

  *)
    echo "Uknown test flavour '${FLAVOUR}'"
    exit 1
    ;;
esac

case "${METHOD?}" in
  yum)
    yum -y install puppet-agent
    ;;
  apt)
    dpkg -i /tmp/puppet.deb
    apt update
    apt -yq install puppet-agent cron systemd

    ;;
  *)
    echo "Unknown install method '${METHOD}'"
    exit 1
    ;;
esac

/opt/puppetlabs/bin/puppet module install choria/choria
/opt/puppetlabs/bin/puppet apply -e 'class{"choria": server => true, manage_service => false}'
choria buildinfo
