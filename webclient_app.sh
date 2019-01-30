#!/bin/bash
# Configure the webclient node app for production
set -ex

# TODO: Review Node process managers: pm2, forever, or supervisor
#       For now, we'll implement the runit process manager used with the circulation containers
#       (runit: http://blog.mobnia.com/using-runit-to-supervise-nodejs-applications/).

# Create app runit service directories
mkdir /etc/sv/webclient_app
mkdir /etc/sv/webclient_app/log
# Create app log directory
mkdir /var/log/webclient_app
chown simplified:simplified /var/log/webclient_app

# Copy runit service files and set executable
cp /ls_build/services/webclient_app.runit /etc/sv/webclient_app/run
cp /ls_build/services/webclient_app_log.runit /etc/sv/webclient_app/log/run
chmod +x /etc/sv/webclient_app/run
chmod +x /etc/sv/webclient_app/log/run

# Create symlink into service directory
ln -s /etc/sv/webclient_app /etc/service/webclient_app

# Do any additional scripts need to run at startup?
# If so, add to startup directory and reference specifically below (do not copy all)
#cp /ls_build/startup/0X_added_script.sh /etc/my_init.d/

app_user_home=/home/simplified

# Create an alias to restart the application.
touch $app_user_home/.bash_aliases
echo "alias restart_app=\`sv restart webclient_app\`" >> $app_user_home/.bash_aliases
chown -R simplified:simplified $app_user_home/.bash_aliases
