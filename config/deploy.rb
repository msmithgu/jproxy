require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

# Basic settings:
# domain     - The hostname to SSH to
# deploy_to  - Path to deploy into
# repository - Git repo to clone from (needed by mina/git)
# user       - Username in the  server to SSH to (optional)

set :domain, 'proxyhub.shrm.org'
set :deploy_to, '/home/proximus/proxyhub.shrm.org'
set :repository, 'git://github.com/msmithgu/jproxy.git'
set :user, 'proximus'
set :term_mode, :pretty
set :bash_options, '-l'

desc "Deploys the current version to proxyhub.shrm.org and restarts the nodejs server."
task :deploy do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    queue 'source ~/.nvm/nvm.sh; nvm use v0.8.1; npm install; npm test'

    to :launch do
      invoke :server_restart
    end
  end
end

desc "Restarts the nodejs server."
task :server_restart do
  invoke :server_kill
  invoke :server_start
end

desc "Kills the nodejs server (and all other node processes)."
task :server_kill do
  queue 'pkill -u proximus node;true'
end

desc "Starts the nodejs server."
task :server_start do
  queue 'cd /home/proximus/proxyhub.shrm.org/current; source ~/.nvm/nvm.sh; nvm use v0.8.1; npm start >> /home/proximus/proxyhub.shrm.org/log 2>&1 & echo starting server'
end

desc "Gets the whole, current nodejs server log file."
task :log do
  queue 'cat /home/proximus/proxyhub.shrm.org/log'
end

desc "Watches the nodejs server log file for changes."
task :log_watch do
  queue 'tail -f /home/proximus/proxyhub.shrm.org/log'
end
