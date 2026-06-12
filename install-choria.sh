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

  trixie_64)
    wget -O /tmp/puppet.deb https://s3.osuosl.org/openvox-apt/openvox8-release-debian13.deb

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

/opt/puppetlabs/puppet/bin/gem install r10k

cd /etc/puppetlabs/code

cat > Puppetfile << EOF
mod "puppetlabs/apt"
mod "puppetlabs/concat"
mod "puppetlabs/stdlib"
mod "puppet/systemd"

# Unfortunately r10k doesnt allow tracking latest with git so this is the next best thing
# to avoid maintaining this after every release
mod "choria/choria", :git => "https://github.com/choria-io/puppet-choria", :branch => "main"
mod "choria/mcollective", :git => "https://github.com/choria-io/puppet-mcollective", :branch => "main"
mod "choria/mcollective_choria", :git => "https://github.com/choria-plugins/mcollective_choria", :branch => "main"
mod "choria/mcollective_agent_filemgr", :git => "https://github.com/choria-plugins/filemgr-agent", :branch => "main"
mod "choria/mcollective_agent_package", :git => "https://github.com/choria-plugins/package-agent", :branch => "main"
mod "choria/mcollective_agent_puppet", :git => "https://github.com/choria-plugins/puppet-agent", :branch => "main"
mod "choria/mcollective_agent_service", :git => "https://github.com/choria-plugins/service-agent", :branch => "main"
mod "choria/mcollective_util_actionpolicy", :git => "https://github.com/choria-plugins/action-policy", :branch => "main"
EOF

/opt/puppetlabs/puppet/bin/r10k puppetfile install -v

/opt/puppetlabs/bin/puppet apply -e 'class{"choria": server => true, manage_service => false}'

choria buildinfo
