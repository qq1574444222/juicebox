#!/bin/bash -eux

echo "==> Disk usage before minimization"
df -h

echo "==> Installed packages before cleanup"
dpkg --get-selections | grep -v deinstall

echo "==> Removing all linux kernels except the currrent one"
dpkg --list | awk '{ print $2 }' | grep 'linux-image-3.*-generic' | grep -v $(uname -r) | xargs apt-get -y purge

echo "==> Removing linux source"
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge

echo "==> Removing documentation"
dpkg --list | awk '{ print $2 }' | grep -- '-doc$' | xargs apt-get -y purge

echo "==> Removing default system Ruby"
apt-get -y purge ruby ri doc

echo "==> Removing default system Python"
apt-get -y purge \
  python-dbus \
  libnl1 \
  python-smartpm \
  python-twisted-core \
  libiw30 \
  python-twisted-bin \
  libdbus-glib-1-2 \
  python-pexpect \
  python-pycurl \
  python-serial \
  python-gobject \
  python-pam \
  python-openssl \
  libffi5

if [ "$JUICEBOX" = "server" ]; then
  echo "==> Removing X11 libraries"
  apt-get -y purge \
    libx11-data \
    xauth libxmuu1 \
    libxcb1 \
    libx11-6 \
    libxext6
fi

echo "==> Removing obsolete networking components"
apt-get -y purge ppp pppconfig pppoeconf

echo "==> Removing other oddities"
apt-get -y purge \
  popularity-contest \
  installation-report \
  landscape-common \
  wireless-tools \
  wpasupplicant \
  ubuntu-serverguide

# Clean up the apt cache
apt-get -y autoremove --purge
apt-get -y autoclean
apt-get -y clean

# Clean up orphaned packages with deborphan
apt-get -y install deborphan
while [ -n "$(deborphan --guess-all --libdevel)" ]; do
  deborphan --guess-all --libdevel | xargs apt-get -y purge
done
apt-get -y purge deborphan dialog

echo "==> Removing man pages"
rm -rf /usr/share/man/*

echo "==> Removing APT files"
find /var/lib/apt -type f | xargs rm -f

echo "==> Removing any docs"
rm -rf /usr/share/doc/*

echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;

echo "==> Disk usage after cleanup"
df -h
