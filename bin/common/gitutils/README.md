# gitutils
Collection of tiny utilities for git.
* gitaccount - manages per-repository git account settings (user.name and user.email).
* privacychk - checks if your private information is accidentally included in your git repository.

## Initial Setup
### gitaccount
Add your accounts using 'gitaccount add'. The following example shows how to add an account for github and another for private repository. The first one is named "github" and the other is named "private".
```
$ gitaccount add github "Your GitHub Name" "your_github_name@public.example.com"
$ gitaccount add private "Your Name" "your_name@private.example.com"
```

### privacychk
Create a file ~/.privacychkrc with a one-line extended regular expression (ERE). The tool simply uses the regex line to do 'grep -ERi' on the current directory and 'git log --pretty=full' output.
```
$ vim ~/.privacychkrc
badword|privatename1|privatename2|xx\.xx\.xy\.xz
```

## Usage
### gitaccount
```
gitaccount use <account> : configure git to locally use <account> in the current repository.
gitaccount clear         : clear local account settings for the current repository.
gitaccount [status]      : show account being used for the current repository.
gitaccount list          : list available account names.
gitaccount show <account>: show the specified account details.
gitaccount add <account> <name> <email>: add an account for the app.
gitaccount help          : show usage.
```

* To use the account "github" for ~/app/myproj:
```
$ cd ~/app/myproj
$ gitaccount use github
```

* To see the account being used for the current repository.
```
$ gitaccount
```

* To remove the local configuraitons and use the global one if any.
```
$ gitaccount clear
```

* Some tips
 - If you want git to reject commit when no account info is set, add the following config.
    ```
    $ git config --global user.useconfigonly true

 - To enforce you to run 'gitaccount use' for each repository, remove global user configuration from git.
    ```
    $ git config --global --unset user.name
    $ git config --global --unset user.email
    ````

### privacychk
Go to a directory and just run the command.
```
$ cd ~/app/gitutils
$ privacychk
```

