# coding: us-ascii
# frozen_string_literal: true

require_relative 'helper'

class TestConstants < Test::Unit::TestCase
  def test_constant_version
    assert do
      Eqq::VERSION.instance_of?(String)
    end

    assert do
      Eqq::VERSION.frozen?
    end

    assert do
      Gem::Version.correct?(Eqq::VERSION)
    end
  end
end
