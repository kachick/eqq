# coding: us-ascii
# frozen_string_literal: true

require_relative 'helper'

class TestEqqSingletonMethods < Test::Unit::TestCase
  include EqqAssertions

  def test_pattern?
    expectation_by_given_value = {
      ->{} => false,
      ->x, y{} => false,
      ->x {} => true,
      Object.new => true,
      Integer => true
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, Eqq.pattern?(given), "given: #{given}")
    end

    assert_false(Eqq.pattern?(BasicObject.new))
  end

  def test_build
    builders = %i[
      OR
      AND
      NAND
      NOR
      XOR
      NOT
      EQ
      SAME
      CAN
      RESCUE
      QUIET
      SEND
      ANYTHING
      BOOLEAN
      NIL
    ]

    assertion_scope = self

    pattern = Eqq.build do
      builders.each do |builder|
        assertion_scope.assert_same(Eqq.method(builder).owner, method(builder).owner)
      end

      OR(42, String)
    end
    assert_product_signature(pattern)
    assert_equal([42, 'string'], [42, nil, BasicObject.new, 'string'].grep(pattern))

    assert_raise_with_message(ArgumentError, /might be mis used .+ in your code/) do
      Eqq.build
    end

    assert_raise(ArgumentError) do
      Eqq.build(42) { OR(42, String) }
    end
  end

  data(
    'When the object does not have #===' => BasicObject.new,
    'When the object has #===, but it is not a Proc' => Integer,
    'When the object is Proc, but it takes shortage of arguments' => -> {true},
    'When the object is Proc, but it takes excess of arguments' => ->_v1, _v2 {true},
    'When the object dose not have `#inspect`' => Eqq.AND(Integer, 42).tap { |product| product.singleton_class.undef_method(:inspect) }
  )
  def test_build_raises_exceptions_for_unexpected_operations(result)
    assert_raise_with_message(Eqq::InvalidProductError, /might be mis used .+ in your code/) do
      Eqq.build { result }
    end
  end
end
