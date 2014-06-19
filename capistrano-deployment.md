
```ruby
# config/deploy.rb
lock '3.1.0'

set :keep_releases, 5
set :user, "deployment_system_user"

set :linked_files, ['config/database.yml']
set :linked_dirs, %w(bin log tmp/pids tmp/cache tmp/sockets tmp/generated vendor/bundle public/system public/assets)

set :application, 'application_name'
set :repo_url, 'git@github.com:equivalent/my-pretty-application.git'
set :scm, :git
set :deploy_to, "/home/#{fetch :user}/apps/#{fetch :application}"

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.1.1'
set :rbenv_roles, :all # default value


namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within fetch(:deployment_setup_path) do
        execute :rake, "unicorn:restart"
      end
    end
  end
  after :finished, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
  
   #after "deploy:finishing", :link_database_yml do
     #on roles(:app) do
       #execute "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
     #end
   #end
end

after 'deploy:finished', 'unicorn:restart'
after 'deploy:finished', 'delayed_job:restart'


```


```ruby
namespace :backup do
  def cmd
    [:backup, 'perform',  '-t validations_backup',
     "-c #{Pathname.new('/home/deploy/apps/my_project/current').join('lib', 'backup', 'config.rb')}"]
  end

  namespace :database do
    task :with_notification do
      on roles(:web) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute(*cmd)
          end
        end
      end
    end

    desc "backup database without mail notification"
    task :without_notification do
      on roles(:web) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            with dont_notify: true do
              execute(*cmd)
            end
          end
        end
      end
    end

    desc "backup database with mail notification"
    task :default => :with_notification
  end
end


cap production backup:database:without_notification
# => cd /home/deploy/apps/my_project/current && ( RBENV_ROOT=~/.rbenv RBENV_VERSION=2.1.1 RAILS_ENV=production DONT_NOTIFY=true /usr/bin/env backup perform -t validations_backup -c /home/deploy/apps/my_project/current/lib/backup/config.rb )

cap production backup:database
# => cd /home/deploy/apps/my_project/current && ( RBENV_ROOT=~/.rbenv RBENV_VERSION=2.1.1 RAILS_ENV=production 
/usr/bin/env backup perform -t validations_backup -c /home/deploy/apps/my_project/current/lib/backup/config.rb )

```



```ruby
# config/deploy/staging.rb

set :rails_env, "staging"
set :branch, "staging"
set :ssh_options, {
  user: fetch(:user),
  forward_agent: true,
  auth_methods: %w(publickey)
}

role :app, %w{123.456.789.123}
role :web, %w{123.456.789.123}
role :db, %w{123.456.789.123}

set :rbenv_path, '/opt/rbenv'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

set :bundle_flags, '--deployment'

```

for password login 

```ruby
ask :password, "Password for #{fetch :user}" 
set :ssh_options, {
  user: fetch(:user),
  forward_agent: true,
  auth_methods: %w(password),
  password: fetch(:password)
}
```
