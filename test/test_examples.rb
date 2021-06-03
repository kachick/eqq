# coding: us-ascii
# frozen_string_literal: true

require_relative 'helper'

class TestExamples < Test::Unit::TestCase
  class ExampleClassForIncludingBuildable
    include Eqq::Buildable

    def example
      [4.2, 42, 42.0, 420].grep(OR(AND(Float, 20..50), Integer))
    end
  end

  def test_examples
    assert_equal([42], [4.2, 42, 42.0, 420].grep(Eqq.AND(Integer, 20..50)))

    assert_equal([true, false], [42, nil, true, false, '', 0].grep(Eqq.BOOLEAN))

    assert_equal([[], {}, nil], [42, [], {}, 'string', Object.new, nil].grep(Eqq.CAN(:to_h)))

    pattern = Eqq.define do
      OR(AND(Float, 20..50), Integer)
    end
    assert_equal('OR(AND(Float, 20..50), Integer)', pattern.inspect)
    assert_equal([42, 42.0, 420], [4.2, 42, 42.0, 420].grep(pattern))

    inverted = Eqq.NOT(pattern)
    assert_equal('NOT(OR(AND(Float, 20..50), Integer))', inverted.inspect)
    assert_equal([4.2], [4.2, 42, 42.0, 420].grep(inverted))

    assert_equal(false, Eqq.SEND(:all?, pattern) === [4.2, 42, 42.0, 420])
    assert_equal(true, Eqq.SEND(:any?, pattern) === [4.2, 42, 42.0, 420])

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
    assert_equal('Should be matched here! :)', ret_in_case)

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
    assert_equal('Should be matched here! :)', ret_in_case)

    assert_equal([42, 42.0, 420], ExampleClassForIncludingBuildable.new.example)
  end
end
