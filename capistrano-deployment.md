
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
end
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
