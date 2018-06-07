# dotfiles
Personal generalized dotfiles for various environments.
Currently cygwin and freebsd are supported.

## Install
Login to your system and clone this repo under the home directory.
```
$ cd
$ git clone git@github.com:genneko/dotfiles.git
or
$ git clone https://github.com/genneko/dotfiles.git
```

Run the install.sh script to create symlinks in $HOME. Those links point to the files and directories in $HOME/dotfiles, whose names begin with an underscore(\_) instead of dot(.).
The script backs up original files and directories before symlinking. The backups are located in ~/.dotfile.bak/YYYY-mm-dd-HHMMSS directory.
```
$ dotfiles/install.sh
```

## Changes
When you want to change dotfiles-based configurations, there are two ways depending on your situation.

### Generic change
If the change is generic enough and can be applied to all your systems, make it into the dotfiles, then commit and push.

### Local change
If the change is local to a specific system or limited range of systems, take the following steps to create an override configuration.

First, create ~/local/dotfiles directory.
```
$ mkdir -p ~/local/dotfiles
```

Then, create an override configuration file in the directory.
Name the file by removing a leading dot. For example, "bashrc" for ".bashrc".
```
$ vim ~/local/dotfiles/bashrc
```
