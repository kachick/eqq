# coding: us-ascii
# frozen_string_literal: true

require_relative 'validatable/classmethods'

module Validation
  # A way of defining accessor with flexible validations.
  # @example define accessor with validations
  #   class Person
  #     include Validation
  #     attr_accessor_with_validation :name, AND(String, /\A\w+(?: \w+)*\z/), &:strip
  #     attr_accessor_with_validation :birthday, Time
  #   end
  module Validatable
    private

    # @param [Proc, Method, #===] condition
    # @param [Object] value
    def _valid?(condition, value)
      !!(
        case condition
        when Proc
          instance_exec(value, &condition)
        when Method
          condition.call(value)
        else
          condition === value
        end
      )
    end
  end
end
