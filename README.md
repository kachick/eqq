# eqq

![Build Status](https://github.com/kachick/eqq/actions/workflows/test_behaviors.yml/badge.svg?branch=main)
[![Gem Version](https://badge.fury.io/rb/eqq.png)](http://badge.fury.io/rb/eqq)

Pattern objects builder

## Usage

Require Ruby 2.6 or later

Add below code into your Gemfile

```ruby
gem 'eqq', '0.0.3'
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

p pattern #=> "OR(AND(Float, 20..50), Integer)"
[4.2, 42, 42.0, 420].grep(pattern) #=> [42, 42.0, 420]

inverted = Eqq.NOT(pattern)
p inverted #=> "NOT(OR(AND(Float, 20..50), Integer))"
[4.2, 42, 42.0, 420].grep(inverted) #=> [4.2]

Eqq.SEND(:all?, pattern) === [4.2, 42, 42.0, 420] #=> false
Eqq.SEND(:any?, pattern) === [4.2, 42, 42.0, 420] #=> true

ret_in_case = (
  case 42
  when pattern
    'Should be matched here! :)'
  when inverted
    'Should not be matched here! :<'
  else
    'Should not be matched here too! :<'
  end
)

p ret_in_case #=> Should be matched here! :)

ret_in_case = (
  case 4.2
  when pattern
    'Should not be matched here! :<'
  when inverted
    'Should be matched here! :)'
  else
    'Should not be matched here too! :<'
  end
)

p ret_in_case #=> Should be matched here! :)

class MyClass
  include Eqq::Buildable

  def example
    [4.2, 42, 42.0, 420].grep(OR(AND(Float, 20..50), Integer))
  end
end
MyClass.new.example #=> [42, 42.0, 420]
```

### Explanation

All products can be called as `pattern === other`.

This signature will fit in most Ruby code.

* `case ~ when` syntax
* Enumerable#grep
* Enumerable#grep_v
* Enumerable#all?
* Enumerable#any?
* Enumerable#none?
* Enumerable#one?
* Enumerable#slice_after
* Enumerable#slice_before

They can take this interface as the `pattern`.

And you already saw. All of patterns can be mixed with other patterns as a parts.
Reuse as you wish!

### Builders

* OR(*patterns) / {Eqq::Buildable#OR} - Product returns `true` when matched even one pattern
* AND(*patterns) / {Eqq::Buildable#AND} - Product returns `true` when matched all patterns
* NOT(pattern) / {Eqq::Buildable#NOT} - Product returns `true` when not matched the pattern
* CAN(*method_names) / {Eqq::Buildable#CAN} - Product returns `true` when it has all of the methods (checked with `respond_to?`)
* RESCUE(exception_class/module, pattern) / {Eqq::Buildable#RESCUE} - Product returns `true` when the pattern raises the exception
* QUIET(*patterns) / {Eqq::Buildable#QUIET} - Product returns `true` when all patterns did not raise any exception
* EQ(object) / {Eqq::Buildable#EQ} - Product returns `true` when matched with `#==`
* SAME(object) / {Eqq::Buildable#SAME} - Product returns `true` when matched with `#equal?`
* SEND(name, pattern) / {Eqq::Buildable#SEND} - Basically provided for Enumerable
* BOOLEAN() / {Eqq::Buildable#BOOLEAN} - Product returns `true` when matched to `true` or `false`
* ANYTHING() / {Eqq::Buildable#ANYTHING} - Product returns `true`, always `true`
* XOR(pattern1, pattern2) / {Eqq::Buildable#XOR} - Product returns `true` when matched one of the pattern, when matched both returns `false`
* NAND(*patterns) / {Eqq::Buildable#NAND} - Product is inverted {Eqq::Buildable#AND}
* NOR(*patterns) / {Eqq::Buildable#NOR} - Product is inverted {Eqq::Buildable#OR}

### Additional information

When you feel annoy to write `Eqq` in many place, 2 ways exist.

* `Eqq.define` - In the block scope, all builder methods can be used without receiver
* `include Eqq::Buildable` - In the class/module, all builders can be used as own method

This gem provides [ruby/rbs](https://github.com/ruby/rbs) signatures

## Links

* [Repository](https://github.com/kachick/eqq)
* [API documents](https://kachick.github.io/eqq)

## NOTE

* [`eqq` is the implementation name of `#===` in CRuby](https://github.com/ruby/ruby/blob/2a685da1fcd928530509e99f5edb4117bc377994/range.c#L1859)
