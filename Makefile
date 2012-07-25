install: install_global install_local

install_local:
	npm install .

install_global:
	npm install -g coffee-script supervisor jasmine-node

install_node:
	git clone git://github.com/creationix/nvm.git ~/.nvm
	echo '. ~/.nvm/nvm.sh' >> ~/.bashrc
	echo '[[ -r $NVM_DIR/bash_completion ]] && . $NVM_DIR/bash_completion' >> ~/.bashrc
	source ~/.bashrc
	nvm install v0.8.1
	nvm use v0.8.1

edit:
	vim -O spec/jproxy.spec.coffee lib/jproxy.coffee

clean:
	rm -rf node_modules

server:
	coffee lib/jproxy.coffee

tester:
	supervisor -e coffee -w 'examples,lib,spec' -n error -n exit -x jasmine-node -- --coffee --verbose spec