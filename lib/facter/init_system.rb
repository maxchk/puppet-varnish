Facter.add(:init_system) do
  confine :kernel => 'Linux'
  setcode do
    proc_1 = Facter::Core::Execution::exec('ps --no-headers -p 1').split(' ')[-1]
    if proc_1 != 'init'
      proc_1
    else
      path_exec = Facter::Core::Execution::exec("ls -l $(which #{proc_1})").split(' ')[-1]
      path_exec.split('/')[-1]
    end
  end
end
