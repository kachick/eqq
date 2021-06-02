# coding: us-ascii
# frozen_string_literal: true

# Copyright (c) 2011 Kenichi Kamiya
# Forked from https://github.com/kachick/validation at 2021

require_relative 'eqq/version'

module Eqq
  class Error < StandardError; end
  class InvalidProductError < Error; end

  INSPECTION_FALLBACK = 'UninspectableObject'
  private_constant :INSPECTION_FALLBACK

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

    # @return [String]
    def safe_inspect(object)
      String.try_convert(object.inspect) || INSPECTION_FALLBACK
    rescue Exception
      # This implementation used `RSpec::Support::ObjectFormatter::UninspectableObjectInspector` as a reference, thank you!
      # ref: https://github.com/kachick/times_kachick/issues/97
      singleton_class = class << object; self; end
      begin
        klass = singleton_class.ancestors.detect { |ancestor| !ancestor.equal?(singleton_class) }
        native_object_id = '%#016x' % (object.__id__ << 1)
        "#<#{klass}:#{native_object_id}>"
      rescue Exception
        INSPECTION_FALLBACK
      end
    end

    # @return [#===]
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
end
