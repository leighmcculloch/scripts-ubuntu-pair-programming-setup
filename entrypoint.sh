#! /usr/bin/env zsh

# Allow using the docker socket without root.
sudo chgrp docker /var/run/docker.sock

# Start-up the GPG-Agent for managing SSH and GPG so they can be used across
# all tmux panes/windows.
eval $(gpg-agent --daemon --enable-ssh-support --disable-scdaemon)

# Start TMUX for all terminal access.
tmux -2 new -d

# Wait while session is alive.
while tmux has-session -t 0
do
  echo TMUX session is up. Available to join.
  sleep 1
done
echo TMUX session is down. Exiting.
