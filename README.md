# eqq

![Build Status](https://github.com/kachick/eqq/actions/workflows/test_behaviors.yml/badge.svg?branch=main)
[![Gem Version](https://badge.fury.io/rb/eqq.png)](http://badge.fury.io/rb/eqq)

Pattern objects builder.

`eqq` means `#===`

## Usage

Require Ruby 2.6 or later

Add below code into your Gemfile

```ruby
gem 'eqq', '>= 0.0.2', '< 0.1.0'
```

### Overview

```ruby
require 'eqq'

[4.2, 42, 42.0, 420].grep(Eqq.AND(Integer, 20..50)) #=> [42]
[42, nil, true, false, '', 0].grep(Eqq.BOOLEAN) #=> [true, false]
[42, [], {}, 'string', Object.new, nil].grep(Eqq.CAN(:to_h)) #=> [[], {}, nil]

pattern = Eqq.define do
  OR(AND(Float, 20..50), Integer)
end
[4.2, 42, 42.0, 420].grep(pattern) #=> [42, 42.0, 420]
```

## Links

* [Repository](https://github.com/kachick/eqq)
* [API documents](https://kachick.github.io/eqq)
