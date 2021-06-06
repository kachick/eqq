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
    def pattern?(object)
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

    # @deprecated Use {pattern?} instead. This will be dropped since `0.1.0`
    def valid?(object)
      pattern?(object)
    end

    # @api private
    def satisfy?(object)
      (Proc === object) && object.lambda? && (object.arity == 1) && object.respond_to?(:inspect)
    end

    # @return [Proc]
    # @raise [InvalidProductError] if the return value is not looks to be built with builders
    def build(&block)
      pattern = DSLScope.new.instance_exec(&block)
      raise InvalidProductError unless satisfy?(pattern)

      pattern
    end

    # @deprecated Use {build} instead. This will be dropped since `0.1.0`
    def define(&block)
      build(&block)
    end
  end
end

require_relative 'eqq/buildable'

module Eqq
  extend Buildable

  class DSLScope
    include Buildable
  end
  private_constant(:DSLScope)
end
