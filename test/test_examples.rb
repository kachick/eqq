# coding: us-ascii
# frozen_string_literal: true

require_relative 'helper'

class TestExamples < Test::Unit::TestCase
  def test_examples
    assert_equal([42], [4.2, 42, 42.0, 420].grep(Eqq.AND(Integer, 20..50)))

    assert_equal([true, false], [42, nil, true, false, '', 0].grep(Eqq.BOOLEAN))

    assert_equal([[], {}, nil], [42, [], {}, 'string', Object.new, nil].grep(Eqq.CAN(:to_h)))

    pattern = Eqq.define do
      OR(AND(Float, 20..50), Integer)
    end
    assert_equal([42, 42.0, 420], [4.2, 42, 42.0, 420].grep(pattern))
  end
end
