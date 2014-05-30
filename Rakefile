require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.send('disable_autoloader_layout')
PuppetLint.configuration.send('disable_nested_classes_or_defines')
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true

exclude_paths = [
  "pkg/**/*",
  "spec/**/*",
  "tests/**/*"
]

PuppetLint.configuration.ignore_paths = exclude_paths

desc "Run syntax, lint, and spec tests."
task :test => [
  :lint,
  :spec,
]
