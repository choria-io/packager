#!/bin/sh

set -e

FLAVOUR=$(cat /etc/packager.txt)
METHOD="apt"

case "${FLAVOUR?}" in
  el8_64)
    rpm -ivh https://s3.osuosl.org/openvox-yum/openvox8-release-el-8.noarch.rpm
    METHOD="yum"

    ;;

  el9_64)
    rpm -ivh https://s3.osuosl.org/openvox-yum/openvox8-release-el-9.noarch.rpm
    METHOD="yum"

    ;;

  el10_64)
    rpm -ivh https://s3.osuosl.org/openvox-yum/openvox8-release-el-10.noarch.rpm
    METHOD="yum"

    ;;

  bullseye_64)
    wget -O /tmp/puppet.deb https://s3.osuosl.org/openvox-apt/openvox8-release-debian11.deb

    ;;

  bookworm_64)
    wget -O /tmp/puppet.deb https://s3.osuosl.org/openvox-apt/openvox8-release-debian12.deb

    ;;

  bionic_64)
    wget -O /tmp/puppet.deb https://s3.osuosl.org/openvox-apt/openvox8-release-ubuntu18.04.deb

    ;;

  focal_64)
    wget -O /tmp/puppet.deb https://s3.osuosl.org/openvox-apt/openvox8-release-ubuntu20.04.deb

    ;;

  noble_64)
    wget -O /tmp/puppet.deb https://s3.osuosl.org/openvox-apt/openvox8-release-ubuntu24.04.deb

    ;;

  *)
    echo "Uknown test flavour '${FLAVOUR}'"
    exit 1
    ;;
esac

case "${METHOD?}" in
  yum)
    yum -y install openvox-agent
    ;;
  apt)
    dpkg -i /tmp/puppet.deb
    apt update
    apt -yq install openvox-agent cron systemd

    ;;
  *)
    echo "Unknown install method '${METHOD}'"
    exit 1
    ;;
esac

/opt/puppetlabs/bin/puppet module install choria/choria
/opt/puppetlabs/bin/puppet apply -e 'class{"choria": server => true, manage_service => false}'
choria buildinfo
