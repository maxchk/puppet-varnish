Facter.add(:init_system) do
  confine :kernel => 'Linux'
  setcode do

    # Active init system process has PID 1
    proc_1 = Facter::Core::Execution::exec('ps --no-headers -p 1').split(' ')[-1]

    # A PID 1 process called `init` can be a link to systemd or upstart
    unless proc_1 == 'init'
      proc_1
    else
      path_exec = Facter::Core::Execution::exec("ls -l $(which #{proc_1})").split(' ')[-1]
      file_exec = path_exec.split('/')[-1]

      # An executable called `init` can be a link to systemd or upstart
      unless file_exec == 'init'
        file_exec
      else

        # Check package which provided running init system executable
        case Facter.value(:osfamily)
        when 'Debian', 'Ubuntu'
          pkg_exec = Facter::Core::Execution::exec("dpkg-query -S #{path_exec}").split(' ')[0]
        when 'RedHat'
          pkg_exec = Facter::Core::Execution::exec("rpm -qf #{path_exec}").split('-')[0]
        # TODO: add similar checks for other distros
        else
          pkg_exec = 'unknown'
        end
        pkg_exec.downcase[/systemd|upstart|init|unknown/]

      end

    end

  end
end
