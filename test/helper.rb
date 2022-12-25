# coding: us-ascii
# frozen_string_literal: true

require 'warning'

# How to use => https://test-unit.github.io/test-unit/en/
require 'test/unit'

require 'irb'
require 'power_assert/colorize'
require 'irb/power_assert'

Warning[:deprecated] = true
Warning[:experimental] = true

Warning.process do |_warning|
  :raise
end

require_relative '../lib/eqq'

class Test::Unit::TestCase
  module EqqAssertions
    def assert_product_signature(product)
      assert_instance_of(Proc, product)
      assert(product.lambda?)
      assert_equal(1, product.arity)
      assert_instance_of(String, product.inspect)
      assert_true(Eqq.satisfy?(product))
    end
  end
end
