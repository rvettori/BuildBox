# BuildBox

BuidBolx try apply security in execution your ruby code when unknown source.

## Installation

Add this line to your application's Gemfile:

    gem 'build_box'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install build_box

## Set It Up

Remove all the bad methods and classes I can think of. But maybe you need more:

```ruby
Sandrbox.configure do |config|
  config.bad_constants << :Rails
  config.bad_constants << :ActiveRecord
  config.timeout = 3 # default seconds by execution
end
```

## How To Use It

```ruby
require 'sandrbox'

# good execution
result = nil
result = BuildBox.perform(' 1 + 2 ');
result.output # => 3
result.error? # => false
result.error # => nil

# bad execution
result = BuildBox.perform(' 1 + nil ');
result.output # => nil
result.error? # => true
result.error # => "exception message"

# execution should be failures
BuildBox.perform('`rm -rf /`').output # => "NameError: undefined local variable or method ``' for Kernel:Module"
BuildBox.perform('exec("rm -rf /")').output # => "NameError: undefined local variable or method `exec' for main:Object" 
BuildBox.perform('Kernel.exec("rm -rf /")').output # => "NameError: undefined local variable or method `exec' for Kernel:Module"BuildBox.perform(['require "open3"']).output # => ["NameError: undefined local variable or method `require' for main:Object"]


```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/build_box/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
