# coding: us-ascii
# frozen_string_literal: true

require 'warning'

# How to use => https://test-unit.github.io/test-unit/en/
require 'test/unit'

require 'irb'
require 'power_assert/colorize'
require 'irb/power_assert'

if Warning.respond_to?(:[]=) # @TODO Removable this guard after dropped ruby 2.6
  Warning[:deprecated] = true
  Warning[:experimental] = true
end

Warning.process do |_warning|
  :raise
end

require_relative '../lib/eqq'

class Test::Unit::TestCase
  module EqqAssertions
    def assert_lambda_signature(product)
      assert_instance_of(Proc, product)
      assert(product.lambda?)
      assert_equal(1, product.arity)
    end
  end
end
