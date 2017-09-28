Facter.add(:init_system) do
  confine :kernel => 'Linux'
  setcode do
    Facter::Core::Execution::exec('ps --no-headers -p 1').split(' ')[-1]
  end
end
