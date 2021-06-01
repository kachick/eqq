# coding: us-ascii
# frozen_string_literal: true

# Copyright (c) 2011 Kenichi Kamiya
# Forked from https://github.com/kachick/validation at 2021

require_relative 'eqq/buildable'
require_relative 'eqq/version'

module Eqq
  extend Buildable

  class Error < StandardError; end
  class InvalidProductError < Error; end

  class DSLScope
    include Buildable
  end

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

    def define(&block)
      pattern = DSLScope.new.instance_exec(&block)
      raise InvalidProductError unless valid?(pattern)

      pattern
    end
  end
end
