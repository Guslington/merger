# merger
Automate merging from origin to upstream repos
Currently is defaulted to develop branches on origin and upstream

### Install Dependencies
Install setup requirements

```sh
brew install git
brew install hub
brew install ghi
```
###Setup Alias
Clone repo and sym-link to ~/bin/merger.sh
Open ~/.bashrc for bash or ~/.zshrc for zsh

```sh
alias merger="~/bin/merger.sh"
```

### How to use
```sh
merger 'comment'

What would you like to do?
[M]erge | [R]etest | [F]ix | [C]lose | [O]pen in browser:

done :D have a lovely day!!
```
