# eqq

![Build Status](https://github.com/kachick/eqq/actions/workflows/test_behaviors.yml/badge.svg?branch=main)
[![Gem Version](https://badge.fury.io/rb/eqq.svg)](http://badge.fury.io/rb/eqq)

Pattern objects builder

## Usage

Require Ruby 3.2 or higher

Add below code into your Gemfile

```ruby
gem 'eqq', '~> 0.1.1'
```

### Overview

```ruby
require 'eqq'

[4.2, 42, 42.0, 420].grep(Eqq.AND(Integer, 20..50)) #=> [42]
[42, nil, true, false, '', 0].grep(Eqq.BOOLEAN) #=> [true, false]
[42, [], {}, 'string', Object.new, nil].grep(Eqq.CAN(:to_h)) #=> [[], {}, nil]

pattern = Eqq.build do
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

- `case ~ when` syntax
- Enumerable#grep
- Enumerable#grep_v
- Enumerable#all?
- Enumerable#any?
- Enumerable#none?
- Enumerable#one?
- Enumerable#slice_after
- Enumerable#slice_before

They can take this interface as the `pattern`.

And you already saw. All of patterns can be mixed with other patterns as a parts.
Reuse as you wish!

### Builders

- OR(*patterns) - Product returns `true` when matched even one pattern
- AND(*patterns) - Product returns `true` when matched all patterns
- NOT(pattern) - Product returns `true` when not matched the pattern
- CAN(*method_names) - Product returns `true` when it has all of the methods (checked with `respond_to?`)
- RESCUE(exception_class/module, pattern) - Product returns `true` when the pattern raises the exception
- QUIET(*patterns) - Product returns `true` when all patterns did not raise any exception
- EQ(object) - Product returns `true` when matched with `#==`
- SAME(object) - Product returns `true` when matched with `#equal?`
- SEND(name, pattern) - Basically provided for Enumerable
- BOOLEAN() - Product returns `true` when matched to `true` or `false`
- NIL() - Product returns `true` when matched to `nil` (Not consider `nil?`)
- ANYTHING() - Product returns `true`, always `true`
- NEVER() - Product returns `false`, always `false`
- XOR(pattern1, pattern2) - Product returns `true` when matched one of the pattern, when matched both returns `false`
- NAND(*patterns) - Product is an inverted `AND`
- NOR(*patterns) - Product is an inverted `OR`

### Best fit for RSpec's `satisfy` matcher too

All builders actually generate a `Proc (lambda)` instance.
The signature will fit for RSpec's built-in ["satisfy" matcher](https://relishapp.com/rspec/rspec-expectations/v/3-10/docs/built-in-matchers/satisfy-matcher) too.

```ruby
RSpec.describe RSpec::Matchers::BuiltIn::Satisfy do
  let(:product) { Eqq.AND(Integer, 24..42) }

  it 'perfectly works' do
    expect(23).not_to satisfy(&product)
    expect(24).to satisfy(&product)
    expect(24.0).not_to satisfy(&product)
    expect(42).to satisfy(&product)
    expect(42.0).not_to satisfy(&product)
    expect(43).not_to satisfy(&product)
  end
end
```

### Use builders without receiver specifying

When you felt annoy to write `Eqq` in many place, some ways exist.

- `Eqq.build(&block)` - In the block scope, all builder methods can be used without receiver
- `extend Eqq::Buildable` - In the class/module, all builders can be used as class methods
- `include Eqq::Buildable` - In the class/module, all builders can be used as instance methods

## Links

- [Repository](https://github.com/kachick/eqq)
- [API documents](https://kachick.github.io/eqq)

## NOTE

- ["eqq" is the implementation name of "#===" in CRuby](https://github.com/ruby/ruby/blob/2a685da1fcd928530509e99f5edb4117bc377994/range.c#L1859)
