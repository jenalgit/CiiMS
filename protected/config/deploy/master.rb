# What is the branch in your Git repository that will be deployed to the server?
set :branch, "#{stage}"

# The application webroot
set :webroot, "var/www"

set :site_root, "/#{webroot}/#{application}/#{stage}"

# What is the user/password that will connect to your Development server?
set :sudo_user, "deployment"
set :user, "deployment"
set :sshgroup, 'www-data'

# What is the directory path used to store your project on the remote server?
set :deploy_to, "#{site_root}/deployments"

# Setup Directories
task :setup_directories do
  run "test -d '#{deploy_to}/persistent' || #{try_sudo} mkdir -p '#{deploy_to}/persistent'"
  run "test -d '#{deploy_to}/persistent/config' || #{try_sudo} mkdir -p '#{deploy_to}/persistent/config'"
end

# Fix Permissions
task :fix_permissions do
    #run "#{try_sudo} chown -R #{sudo_user}:#{sshgroup}  #{deploy_to}"
end

# Copy the config directories over to the persistent directory, and re-link the directories
task :move_configs do
	run "cp -R #{deploy_to}/current/protected/config/* '#{deploy_to}/persistent/config/'"
	run "rm -rf #{deploy_to}/current/protected/config"
	run "ln -s '#{deploy_to}/persistent/config/' '#{deploy_to}/current/protected/'"
end

task :migrate do
	run "cd /#{webroot}/#{application}/#{stage}/deployments/current/protected/ && php yiic.php migrate --interactive=0"
end

# After Actions
after "deploy:setup", :setup_directories
after "deploy:setup", :fix_permissions
after "deploy", :move_configs