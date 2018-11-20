require 'sshkit/sudo'

namespace :procsd do
  desc "Create or restart (if already created) app services"
  task :create_or_restart do
    on roles(:all) do
      within "#{deploy_to}/current" do
        cmd = %i(procsd create --or-restart)
        cmd << :'--add-to-sudoers' if fetch(:procsd_sudoers_at_create_or_restart)

        execute! *cmd
      end
    end
  end

  desc "Create app services"
  task :create, :arguments do |t, args|
    arguments = args[:arguments]

    on roles(:all) do
      within "#{deploy_to}/current" do
        execute! :procsd, :create, arguments
      end
    end
  end

  desc "Destroy app services"
  task :destroy do
    on roles(:all) do
      within release_path do
        execute! :procsd, :destroy
      end
    end
  end

  ###

  desc "Start app services"
  task :start do
    on roles(:all) do
      within release_path do
        execute! :procsd, :start
      end
    end
  end

  desc "Stop app services"
  task :stop do
    on roles(:all) do
      within release_path do
        execute! :procsd, :stop
      end
    end
  end

  desc "Restart app services"
  task :restart do
    on roles(:all) do
      within release_path do
        execute! :procsd, :restart
      end
    end
  end

  ###

  desc "Check status of app services"
  task :status, :arguments do |t, args|
    arguments = args[:arguments]

    on roles(:all) do
      ssh_exec cmd_with_env("procsd status #{arguments}"), task_name: :status
    end
  end

  desc "Check app services logs"
  task :logs, :arguments do |t, args|
    arguments = args[:arguments]

    on roles(:all) do
      ssh_exec cmd_with_env("procsd logs #{arguments}"), task_name: :logs
    end
  end

  desc "List all services"
  task :list do
    on roles(:all) do
      ssh_exec cmd_with_env("procsd list"), task_name: :list
    end
  end

  ###

  desc "Run command on a remote server"
  task :run, :cmd do |t, args|
    cmd = args[:cmd]
    raise "Please provide a command to run" if cmd.nil? || cmd.empty?
    # Automatically prepend -l option (login shell) for a bash command:
    cmd += " -l" if cmd == "bash"

    on roles(:all) do
      ssh_exec cmd_with_env(cmd), task_name: :run
    end
  end

  ###

  private def cmd_with_env(cmd)
    cmd = cmd.strip.split(" ", 2)
    cmd[0] = cmd[0].to_sym
    command(cmd, {}).to_s
  end

  private def ssh_exec(command, task_name:)
    full_command = %W(ssh #{host.user}@#{host.hostname} -t)

    ssh_options = fetch(:ssh_options, {})
    ssh_options[:keys]&.each { |key_path| full_command.push("-i", key_path) }
    full_command.push("-A") unless ssh_options[:forward_agent] == false
    full_command.push("-p", ssh_options[:port]) if ssh_options[:port]

    command = "'cd #{release_path} && #{command}'"
    full_command << command

    cmd = full_command.join(" ")
    puts Airbrussh::Colors.blue("procsd:#{task_name} ") + Airbrussh::Colors.yellow(cmd)
    exec cmd
  end
end
