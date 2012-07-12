jproxy
======

Development
-----------

    # Install dev stuff globally
    npm install -g coffee-script supervisor jasmine-node

    # Setup tester
    supervisor -e coffee -w 'lib,spec' -n error -n exit -x jasmine-node -- --coffee --verbose spec
