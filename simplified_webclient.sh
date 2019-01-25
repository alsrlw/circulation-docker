#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

repo="$1"
version="$2"

# Add a PPA repo for obtaining version 10.x of Node.json
curl -sL https://deb.nodesource.com/setup_10.x | bash -

# TODO: Any additional tools/utilities? (tzdata, etc.?)
apt-get update && $minimal_apt_get_install git \
  nodejs

# Create a user.
useradd -ms /bin/bash -U simplified

# Get the proper version of the codebase.
mkdir /var/www && cd /var/www
git clone https://github.com/${repo}.git webclient
chown simplified:simplified webclient
cd webclient
# TODO: A version tag is not currently supported, but should be in future development
# Instead, temporarily, default to master (see Dockerfile)
git checkout $version

# Add a .version file to the directory. This file
# supplies an endpoint to check the app's current version.
# ?Good idea for future?
#printf "$(git describe --tags)" > .version

# Install packages from main packages.json file
npm install

# TODO: Add Node process manager here? pm2, or forever/supervisor mentioned by Amy, or 
# runit are options (runit: http://blog.mobnia.com/using-runit-to-supervise-nodejs-applications/).
# Runit is already the process manager of choice for the nginx.sh script


# TODO: Review items below to determine which needs to be kept, altered, or removed
# Link the repository code to /home/simplified and change permissions
su - simplified -c "ln -s /var/www/webclient /home/simplified/webclient"
chown -RHh simplified:simplified /home/simplified/webclient

# Copy webclient libraries list/config sample file, if the config file option is chosen
if [ -n "$CONFIG_FILE" ]; then
  cp /ls_build/services/webclient_libraries.conf $CONFIG_FILE
  chown -RHh simplified:simplified $CONFIG_FILE
fi

# Give logs a place to go.
mkdir /var/log/simplified

# Do any additional scripts need to run at startup?
# If so, add to startup directory and reference specifically below (do not copy all)
#cp /ls_build/startup/0X_added_script.sh /etc/my_init.d/