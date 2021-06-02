# coding: us-ascii
# frozen_string_literal: true

# Copyright (c) 2011 Kenichi Kamiya
# Forked from https://github.com/kachick/validation at 2021

require_relative 'eqq/version'

# Pattern objects builder
module Eqq
  # Base error of this library
  class Error < StandardError; end

  # Raised when found some products are invalid as a pattern object
  class InvalidProductError < Error; end

  class << self
    def valid?(object)
      case object
      when Proc, Method
        object.arity == 1
      else
        begin
          object.respond_to?(:===)
        rescue NoMethodError
          false
        end
      end
    end

    # @return [#===]
    # @raise [InvalidProductError] if the return value is invalid as a pattern object
    def define(&block)
      pattern = DSLScope.new.instance_exec(&block)
      raise InvalidProductError unless valid?(pattern)

      pattern
    end
  end
end

require_relative 'eqq/buildable'

module Eqq
  extend Buildable

  class DSLScope
    include Buildable
  end
  private_constant :DSLScope
end
