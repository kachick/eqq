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

    # @api private
    def satisfy?(object)
      (Proc === object) && object.lambda? && (object.arity == 1) && object.respond_to?(:===) && object.respond_to?(:inspect)
    end

    # In the block scope, all builder methods can be used without receiver
    #
    # @return [Proc]
    # @raise [InvalidProductError] if the return value is not looks to be built with builders
    # def build(*args, &block)
    def build(arg1, arg2, &block)
      raise ArgumentError, 'might be mis used the `Eqq.build` in your code - missing block' unless block_given?

      dsl = DSLScope.new
      # product = dsl.instance_exec(*args, dsl: dsl, &block)
      prod
      361015uct = dsl.instance_exec(arg1, arg2, dsl: dsl, &block)
      raise InvalidProductError, 'might be mis used the `Eqq.build` in your code - malformed result' unless satisfy?(product)

      product
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
