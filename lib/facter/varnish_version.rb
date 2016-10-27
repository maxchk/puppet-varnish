Facter.add(:varnish_version) do
  setcode do
    if Facter.value('kernel') != 'windows' && Facter::Util::Resolution.which('varnishd')
      varnish_version = Facter::Util::Resolution.exec('varnishd -V 2>&1')
      %r{varnishd \(varnish-([\w\.]+)}.match(varnish_version)[1]
    end
  end
end
