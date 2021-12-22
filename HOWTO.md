# Terraforming How-to Contribute

## Install `rvm`
```sh
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
sudo gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
sudo apt-get install software-properties-common
sudo apt-add-repository -y ppa:rael-gc/rvm
sudo apt-get update
sudo apt-get install rvm
sudo usermod -a -G rvm yourusername
sudo reboot
```

## Install debug tools
```sh
gem install pry
gem install yaml
gem install rdoc
```

## Install ruby build tools and docs
```sh
brew upgrade                        # default gcc was v5 need > 7
sudo apt-get install rbenv          # helpful in addition to rvm
sudo apt-get install ruby-dev       # needed for gem installers
sudo rvm install 2.4.1              # might not be needed, I can't remember
rvm docs generate                   # install docs
rvm docs generate-ri                # install ri compatible docs
```

## To create new modules for `terraforming`
```sh
brew unlink ruby                    # only needed if ruby was installed with homebrew
rbenv global 2.4.1                  # install Ruby v2.4.1 for entire system
rvm use ruby-2.4.10                 # use ruby v2.4.10
cd terraforming && script/setup     # install everything needed to contribute to terraforming

# make your stuff
rake -t                             # shows what rake tasks there are
rake                                # runs default rake tasks
rake spec                           # runs RSpec tests
rake build                          # builds new version
rake install                        # installs new version to system
```

## To debug your stuff
```sh
require "pry"                       # includes the pry debug library

# in your code where you want a breakpoint add:
binding.pry

# helpful commands
puts whatever.methods.to_yaml       # like pprint in python (sort of)
help                                # will reference ri documentation
``