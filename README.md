jproxy
======

Development
-----------

    # Setup node and npm using nvm (assuming you're using bash (adjust if otherwise))
    git clone git://github.com/creationix/nvm.git ~/nvm
    echo '
    . ~/nvm/nvm.sh
    [[ -r $NVM_DIR/bash_completion ]] && . $NVM_DIR/bash_completion
    ' >> ~/.bashrc
    source ~/.bashrc

    nvm install v0.8.1
    nvm use v0.8.1

    # Install dev stuff globally
    npm install -g coffee-script supervisor jasmine-node

    # Install required node modules
    npm install .

    # Setup tester
    supervisor -e coffee -w 'lib,spec' -n error -n exit -x jasmine-node -- --coffee --verbose spec
