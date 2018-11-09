# Capistrano::Procsd

Capistrano integration for [Procsd](https://github.com/vifreefly/procsd). All available tasks:

```
cap procsd:create[arguments]       # Create app services
cap procsd:create_or_restart       # Create or restart (if already created) app services
cap procsd:destroy                 # Destroy app services
cap procsd:list                    # List all services
cap procsd:logs[arguments]         # Check app services logs
cap procsd:restart                 # Restart app services
cap procsd:run[cmd]                # Run command on the remote server
cap procsd:start                   # Start app services
cap procsd:status[arguments]       # Check status of app services
cap procsd:stop                    # Stop app services
```

## Configuration

Add to your application `Gemfile` somewhere:

```ruby
# Gemfile

group :development do
  gem 'capistrano-procsd' require: false
end
```

Require procsd tasks inside `Capfile`:

```ruby
# Capfile

require 'capistrano/procsd'
```

And finally add hook to call `procsd:create_or_restart` task each time after publishing:

```ruby
# config/deploy.rb

after "deploy:publishing", "procsd:create_or_restart"
```

Done!

### Note about procsd location on the remote server

Configuration above assumes that you have `$ procsd` executable somewhere in the system path on your remote server. You can install gem system-wide this way:

```bash
# Install ruby system-wide from apt repositories:
$ sudo apt install ruby

# Install procsd gem system-wide:
$ sudo gem install procsd
```

Or, if you already use [Rbenv](https://github.com/rbenv/rbenv) you can do instead following:

Add `procsd` gem to your application Gemfile:

```ruby
# Gemfile

group :development do
  # You're probably already have it
  gem 'capistrano-rbenv', require: false
  gem 'capistrano-bundler', require: false
end

# Add procsd gem
gem 'procsd', require: false
```

Require `capistrano/rbenv` and `capistrano/bundler` inside Capfile (if not required yet):

```ruby
# Capfile

require 'capistrano/rbenv'
require 'capistrano/bundler'
```

And finally add `procsd` to rbenv and bundle bins:

```ruby
# config/deploy.rb

append :rbenv_map_bins, "procsd"
append :bundle_bins, "procsd"
```

## Usage

At the first deploy `$ bundle exec cap production deploy` app services will be created and started. You will be prompted to fill in remote user password (make sure that your deploy user added to the sudo group `adduser deploy sudo`).

If you don't want to type password each time while deploying, you can add start/stop/restart commands to the sudoers file:

1. Login to the remote server, `cd` into application folder, and type `$ procsd config sudoers`. Example:

```
deploy@server:~/sample_app/current$ procsd config sudoers

deploy ALL=NOPASSWD: /bin/systemctl start sample_app.target, /bin/systemctl stop sample_app.target, /bin/systemctl restart sample_app.target
```

2. Copy sudoers rule from above to the sudoers file (just type `$ sudo visudo` and paste line at the bottom then save and exit). Logout from the server.

Now try to call restart task `$ bundle exec cap production procsd:restart`. If all is fine, task will execute without password prompt.


**Also, steps above can be done automatically:**

```ruby
# config/deploy.rb

# pass `--add-to-sudoers` option to the `procsd create` command:
set :procsd_sudoers_at_create_or_restart, true
```

Now sudoers rule will be added at the first deploy automatically.

## Examples

* `bundle exec cap production procsd:logs[-t]` - Tail application logs
* `bundle exec cap production procsd:run[bash]` - `ssh` into app server, `cd` into app directory and leave the bash session open

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
