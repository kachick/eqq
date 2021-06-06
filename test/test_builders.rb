# coding: us-ascii
# frozen_string_literal: true

require_relative 'helper'

class TestBuilders < Test::Unit::TestCase
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

    assert_raise(ArgumentError) do
      Eqq.OR()
    end

    assert_raise(ArgumentError) do
      Eqq.OR(42)
    end

    assert_product_signature(Eqq.OR(42, 53))

    evil = []
    class << evil
      undef_method :===
    end
    assert_raise_with_message(ArgumentError, /given `\[\], #<BasicObject\S+` are invalid as pattern objects/) do
      Eqq.OR(evil, 42, BasicObject.new)
    end
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

    assert_raise(ArgumentError) do
      Eqq.NOR()
    end

    assert_raise(ArgumentError) do
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

    assert_raise(ArgumentError) do
      Eqq.XOR()
    end

    assert_raise(ArgumentError) do
      Eqq.XOR(42)
    end

    assert_raise(ArgumentError) do
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

    assert_raise(ArgumentError) do
      Eqq.AND()
    end

    assert_raise(ArgumentError) do
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

    assert_raise(ArgumentError) do
      Eqq.NAND()
    end

    assert_raise(ArgumentError) do
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

    assert_raise(ArgumentError) do
      Eqq.CAN()
    end

    assert_raise(ArgumentError) do
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

    assert_raise(ArgumentError) do
      Eqq.SAME()
    end

    assert_raise(ArgumentError) do
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

    assert_raise(ArgumentError) do
      Eqq.EQ()
    end

    assert_raise(ArgumentError) do
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

    assert_raise(ArgumentError) do
      Eqq.NOT()
    end

    assert_raise(ArgumentError) do
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

    assert_raise(ArgumentError) do
      Eqq.RESCUE()
    end

    assert_raise(ArgumentError) do
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

    assert_raise(ArgumentError) do
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

    assert_raise(NoMethodError) do
      pattern === Object.new
    end
  end

  def test_BOOLEAN
    pattern = Eqq.BOOLEAN()
    assert_product_signature(pattern)
    assert_equal('BOOLEAN()', pattern.inspect)
    assert_same(Eqq.BOOLEAN(), Eqq.BOOLEAN())

    [false, true].each do |given|
      assert_true(pattern === given, "given: #{given}")
    end
    [42, nil, '', Object.new, [], {}, 0].each do |given|
      assert_false(pattern === given, "given: #{given}")
    end
    assert_false(pattern === BasicObject.new)
  end

  def test_NIL_signature
    pattern = Eqq.NIL()
    assert_product_signature(pattern)
    assert_equal('NIL()', pattern.inspect)
    assert_same(Eqq.NIL(), Eqq.NIL())

    assert_raise(ArgumentError) do
      Eqq.NIL(Integer)
    end
  end

  data(
    'When given `nil`' => [true, nil],
    'When given object overwrites `#nil?` as truthy' => [false, Class.new { def nil?; true; end }.new],
    'When given `false`' => [false, false],
    'When given `0`' => [false, 0],
    'When given empty collection' => [false, []],
    'When given `true`' => [false, true],
    'When given `42`' => [false, 42],
    'When given a Object' => [false, Object.new],
    'When given a BasicObject' => [false, BasicObject.new]
  )
  def test_NIL_for_typical_values(expected_and_given)
    expected, given = *expected_and_given
    assert_equal(expected, Eqq.NIL() === given)
  end

  def test_ANYTHING
    pattern = Eqq.ANYTHING()
    assert_product_signature(pattern)
    assert_equal('ANYTHING()', pattern.inspect)
    assert_same(Eqq.ANYTHING(), Eqq.ANYTHING())

    [42, nil, false, true, 'string', Object.new, [], {}].each do |given|
      assert_true(pattern === given, "given: #{given}")
    end
    assert_true(pattern === BasicObject.new)
  end

  def test_NEVER
    pattern = Eqq.NEVER()
    assert_product_signature(pattern)
    assert_equal('NEVER()', pattern.inspect)
    assert_same(Eqq.NEVER(), Eqq.NEVER())

    [42, nil, false, true, 'string', Object.new, [], {}].each do |given|
      assert_false(pattern === given, "given: #{given}")
    end
    assert_false(pattern === BasicObject.new)
  end
end
