#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

repo="$1"
version="$2"

# Add a PPA repo for obtaining version 8.x of Node.json
curl -sL https://deb.nodesource.com/setup_8.x | bash -

# TODO: Any additional tools/utilities? (tzdata, etc.?)
apt-get update && $minimal_apt_get_install git \
  nodejs

# Create a user.
useradd -ms /bin/bash -U simplified

# Change to simplified user
su simplified

# Get the proper version of the codebase.
git clone https://github.com/${repo}.git webclient
cd webclient
# TODO: A version tag is not currently supported, but should be in future development
# Instead, temporarily, default to master (see Dockerfile)
git checkout $version

# Add a .version file to the directory. This file
# supplies an endpoint to check the app's current version.
# ?Good idea for future?
#printf "$(git describe --tags)" > .version

# Install dependencies/packages from main packages.json file
# If a development environment is determined, a dependency on fsevents causes
# errors if not on OS X
npm install --production

# Return to root user
exit

mkdir /var/www && cd /var/www
# Link the repository code to /home/simplified and change permissions to simplified user
ln -s /var/www/webclient /home/simplified/webclient
# Set correct ownership of symlink (-h without affecting ownership of target)
chown -RHh simplified:simplified /var/www/webclient

# Copy webclient libraries config list sample file, if the config file option is chosen
if [ -n "$CONFIG_FILE" ]; then
  cp /ls_build/services/webclient_libraries.conf $CONFIG_FILE
  chown -RHh simplified:simplified $CONFIG_FILE
fi

