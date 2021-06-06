# coding: us-ascii
# frozen_string_literal: true

require_relative 'helper'

class TestBasicFeatures < Test::Unit::TestCase
  include EqqAssertions

  def test_OR
    pattern = Eqq.OR(42, 53, 64, 75)
    assert_product_signature(pattern)
    assert_equal('OR(42, 53, 64, 75)', pattern.inspect)
    assert(pattern.inspect.frozen?)

    expectation_by_given_value = {
      42 => true,
      53 => true,
      64 => true,
      75 => true,
      42.0 => true,
      nil => false,
      Object.new => false,
      42.1 => false,
      41 => false,
      76 => false
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, pattern === given, "given: #{given}")
    end

    assert_raises(ArgumentError) do
      Eqq.OR()
    end

    assert_raises(ArgumentError) do
      Eqq.OR(42)
    end

    assert_product_signature(Eqq.OR(42, 53))

    evil = []
    class << evil
      undef_method :===
    end
    err = assert_raises(ArgumentError) do
      Eqq.OR(evil, 42, BasicObject.new)
    end
    assert_match(/given `\[\], #<BasicObject\S+` are invalid as pattern objects/, err.message)
  end

  def test_NOR
    pattern = Eqq.NOR(42, 53, 64, 75)
    assert_product_signature(pattern)
    assert_equal('NOT(OR(42, 53, 64, 75))', pattern.inspect)

    expectation_by_given_value = {
      42 => false,
      53 => false,
      64 => false,
      75 => false,
      42.0 => false,
      nil => true,
      Object.new => true,
      42.1 => true,
      41 => true,
      76 => true
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, pattern === given, "given: #{given}")
    end

    assert_raises(ArgumentError) do
      Eqq.NOR()
    end

    assert_raises(ArgumentError) do
      Eqq.NOR(42)
    end

    assert_product_signature(Eqq.NOR(42, 53))
  end

  def test_XOR
    pattern = Eqq.XOR(/\d/, Symbol)
    assert_product_signature(pattern)
    assert_equal('XOR(/\d/, Symbol)', pattern.inspect)

    expectation_by_given_value = {
      'foo42bar' => true,
      :foo42bar => false,
      42 => false,
      :foobar => true,
      :foo42baz => false,
      nil => false,
      Object.new => false
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, pattern === given, "given: #{given}")
    end

    assert_raises(ArgumentError) do
      Eqq.XOR()
    end

    assert_raises(ArgumentError) do
      Eqq.XOR(42)
    end

    assert_raises(ArgumentError) do
      Eqq.XOR(42, 43, 44)
    end
  end

  def test_AND
    pattern = Eqq.AND(/\d/, Symbol, /bar/)
    assert_product_signature(pattern)
    assert_equal('AND(/\d/, Symbol, /bar/)', pattern.inspect)

    expectation_by_given_value = {
      'foo42bar' => false,
      :foo42bar => true,
      42 => false,
      :foobar => false,
      :foo42baz => false,
      nil => false,
      Object.new => false
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, pattern === given, "given: #{given}")
    end

    assert_raises(ArgumentError) do
      Eqq.AND()
    end

    assert_raises(ArgumentError) do
      Eqq.AND(42)
    end

    assert_product_signature(Eqq.AND(42, Integer))
  end

  def test_NAND
    pattern = Eqq.NAND(/\d/, Symbol, /bar/)
    assert_product_signature(pattern)
    assert_equal('NOT(AND(/\d/, Symbol, /bar/))', pattern.inspect)

    expectation_by_given_value = {
      'foo42bar' => true,
      :foo42bar => false,
      42 => true,
      :foobar => true,
      :foo42baz => true,
      nil => true,
      Object.new => true
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, pattern === given, "given: #{given}")
    end

    assert_raises(ArgumentError) do
      Eqq.NAND()
    end

    assert_raises(ArgumentError) do
      Eqq.NAND(42)
    end

    assert_product_signature(Eqq.NAND(42, Integer))
  end

  def test_CAN
    not_matched1 = Class.new do
      def foo; end
    end.new
    not_matched2 = Class.new do
      def bar; end
    end.new
    matched = Class.new do
      def foo; end
      def bar; end
    end.new
    pattern = Eqq.CAN(:foo, :bar)
    assert_product_signature(pattern)
    assert_equal('CAN(:foo, :bar)', pattern.inspect)

    expectation_by_given_value = {
      not_matched1 => false,
      not_matched2 => false,
      matched => true,
      nil => false,
      Object.new => false
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, pattern === given, "given: #{given}")
    end

    assert_false(pattern === BasicObject.new)

    assert_raises(ArgumentError) do
      Eqq.CAN()
    end

    assert_raises(ArgumentError) do
      Eqq.CAN(42)
    end

    assert_product_signature(Eqq.CAN('foo'))
  end

  def test_SAME
    pattern = Eqq.SAME(42)
    assert_product_signature(pattern)
    assert_equal('SAME(42)', pattern.inspect)

    expectation_by_given_value = {
      42 => true,
      53 => false,
      42.0 => false,
      nil => false,
      Object.new => false,
      42.1 => false
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, pattern === given, "given: #{given}")
    end
    assert_false(pattern === BasicObject.new)

    assert_raises(ArgumentError) do
      Eqq.SAME()
    end

    assert_raises(ArgumentError) do
      Eqq.SAME(42, 43)
    end
  end

  def test_EQ
    pattern = Eqq.EQ(42)
    assert_product_signature(pattern)
    assert_equal('EQ(42)', pattern.inspect)

    expectation_by_given_value = {
      42 => true,
      53 => false,
      42.0 => true,
      nil => false,
      Object.new => false,
      42.1 => false
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, pattern === given, "given: #{given}")
    end
    assert_false(pattern === BasicObject.new)

    assert_raises(ArgumentError) do
      Eqq.EQ()
    end

    assert_raises(ArgumentError) do
      Eqq.EQ(42, 43)
    end
  end

  def test_NOT
    pattern = Eqq.NOT(Eqq.EQ(42))
    assert_product_signature(pattern)
    assert_equal('NOT(EQ(42))', pattern.inspect)

    expectation_by_given_value = {
      42 => false,
      53 => true,
      42.0 => false,
      nil => true,
      Object.new => true,
      42.1 => true
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, pattern === given, "given: #{given}")
    end
    assert_true(pattern === BasicObject.new)

    assert_raises(ArgumentError) do
      Eqq.NOT()
    end

    assert_raises(ArgumentError) do
      Eqq.NOT(Eqq.EQ(42), Eqq.EQ(43))
    end
  end

  def test_RESCUE_with_Exception
    pattern = Eqq.RESCUE(NoMethodError, Eqq.SEND(:any?, Integer))
    assert_product_signature(pattern)
    assert_equal('RESCUE(NoMethodError, SEND(:any?, Integer))', pattern.inspect)

    expectation_by_given_value = {
      [] => false,
      {} => false,
      42 => true,
      nil => true,
      Object.new => true
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, pattern === given, "given: #{given}")
    end
    assert_true(pattern === BasicObject.new)

    assert_raises(ArgumentError) do
      Eqq.RESCUE()
    end

    assert_raises(ArgumentError) do
      Eqq.RESCUE(NoMethodError)
    end
  end

  def test_RESCUE_with_Module
    mod = Module.new
    custom_error1 = Class.new(Exception)
    custom_error2 = Class.new(custom_error1) do
      include mod
    end

    custom_error1_raiser = Class.new do
      define_method :raise_error do |*_args|
        raise custom_error1
      end
    end.new

    custom_error2_raiser = Class.new do
      define_method :raise_error do |*_args|
        raise custom_error2
      end
    end.new

    pattern = Eqq.RESCUE(mod, Eqq.SEND(:raise_error, Integer))
    assert_product_signature(pattern)
    assert_false(pattern === custom_error1_raiser)
    assert_true(pattern === custom_error2_raiser)
  end

  def test_QUIET
    pattern = Eqq.QUIET(Eqq.SEND(:any?, Integer), Eqq.SEND(:all?, String))
    assert_product_signature(pattern)
    assert_equal('QUIET(SEND(:any?, Integer), SEND(:all?, String))', pattern.inspect)

    expectation_by_given_value = {
      [] => true,
      {} => true,
      42 => false,
      nil => false,
      Object.new => false
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, pattern === given, "given: #{given}")
    end
    assert_false(pattern === BasicObject.new)

    assert_raises(ArgumentError) do
      Eqq.QUIET()
    end

    assert_product_signature(Eqq.QUIET(Eqq.SEND(:any?, Integer)))
  end

  def test_SEND
    pattern = Eqq.SEND(:all?, /foo/)
    assert_product_signature(pattern)
    assert_equal('SEND(:all?, /foo/)', pattern.inspect)

    assert_true(pattern === ['foo', :foo, 'foobar'])
    assert_false(pattern === ['foo', :foo, 'foobar', 'baz'])
    assert_false(pattern === [BasicObject.new])

    assert_raises(NoMethodError) do
      pattern === Object.new
    end
  end

  def test_BOOLEAN
    pattern = Eqq.BOOLEAN
    assert_product_signature(pattern)
    assert_equal('BOOLEAN()', pattern.inspect)

    [false, true].each do |given|
      assert_true(pattern === given, "given: #{given}")
    end
    [42, nil, '', Object.new, [], {}, 0].each do |given|
      assert_false(pattern === given, "given: #{given}")
    end
    assert_false(pattern === BasicObject.new)
  end

  def test_ANYTHING
    pattern = Eqq.ANYTHING
    assert_product_signature(pattern)
    assert_equal('ANYTHING()', pattern.inspect)

    [42, nil, false, true, 'string', Object.new, [], {}].each do |given|
      assert_true(pattern === given, "given: #{given}")
    end
    assert_true(pattern === BasicObject.new)
  end

  def test_NEVER
    pattern = Eqq.NEVER
    assert_product_signature(pattern)
    assert_equal('NEVER()', pattern.inspect)

    [42, nil, false, true, 'string', Object.new, [], {}].each do |given|
      assert_false(pattern === given, "given: #{given}")
    end
    assert_false(pattern === BasicObject.new)
  end

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

  def test_valid?
    expectation_by_given_value = {
      ->{} => false,
      ->x, y{} => false,
      ->x {} => true,
      Object.new => true,
      Integer => true
    }

    expectation_by_given_value.each_pair do |given, expectation|
      assert_equal(expectation, Eqq.valid?(given), "given: #{given}")
    end

    assert_false(Eqq.valid?(BasicObject.new))
  end

  def test_define
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
    ]

    assertion_scope = self

    pattern = Eqq.define do
      builders.each do |builder|
        assertion_scope.assert_same(Eqq.method(builder).owner, method(builder).owner)
      end

      OR(42, String)
    end
    assert_product_signature(pattern)
    assert_equal([42, 'string'], [42, nil, BasicObject.new, 'string'].grep(pattern))
  end

  data(
    'When the object does not have #===' => BasicObject.new,
    'When the object has #===, but it is not a Proc' => Integer,
    'When the object is Proc, but it takes shortage of arguments' => -> {true},
    'When the object is Proc, but it takes excess of arguments' => ->_v1, _v2 {true}
  )
  def test_define_raises_exceptions_for_unexpected_operations(result)
    assert_raises(Eqq::InvalidProductError) do
      Eqq.define { result }
    end
  end
end
