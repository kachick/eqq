# coding: us-ascii
# frozen_string_literal: true

module Eqq
  module Buildable
    extend self

    class << self
      INSPECTION_FALLBACK = 'UninspectableObject'

      # @api private
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

      # @api private
      # @return [void]
      def set_inspect(name:, product:, arguments:)
        inspect = "#{name}(#{arguments.map { |argument| safe_inspect(argument) }.join(', ')})".freeze
        product.define_singleton_method(:inspect) do
          inspect
        end
      end

      # @api private
      # @return [void]
      def validate_patterns(*patterns)
        invalids = patterns.reject { |pattern| Eqq.valid?(pattern) }
        invalid_inspections = invalids.map { |invalid| safe_inspect(invalid) }.join(', ')
        raise ArgumentError, "given `#{invalid_inspections}` are invalid as pattern objects" unless invalids.empty?
      end
    end

    # @param pattern1 [Proc, Method, #===]
    # @param pattern2 [Proc, Method, #===]
    # @param patterns [Array<Proc, Method, #===>]
    # @return [Proc]
    def AND(pattern1, pattern2, *patterns)
      patterns = [pattern1, pattern2, *patterns].freeze
      Buildable.validate_patterns(*patterns)

      product = ->v {
        patterns.all? { |pattern| pattern === v }
      }

      Buildable.set_inspect(name: 'AND', product: product, arguments: patterns)

      product
    end

    # @param pattern1 [Proc, Method, #===]
    # @param pattern2 [Proc, Method, #===]
    # @param patterns [Array<Proc, Method, #===>]
    # @return [Proc]
    def NAND(pattern1, pattern2, *patterns)
      NOT(AND(pattern1, pattern2, *patterns))
    end

    # @param pattern1 [Proc, Method, #===]
    # @param pattern2 [Proc, Method, #===]
    # @param patterns [Array<Proc, Method, #===>]
    # @return [Proc]
    def OR(pattern1, pattern2, *patterns)
      patterns = [pattern1, pattern2, *patterns].freeze
      Buildable.validate_patterns(*patterns)

      product = ->v {
        patterns.any? { |pattern| pattern === v }
      }
      Buildable.set_inspect(name: 'OR', product: product, arguments: patterns)

      product
    end

    # @param pattern1 [Proc, Method, #===]
    # @param pattern2 [Proc, Method, #===]
    # @param patterns [Array<Proc, Method, #===>]
    # @return [Proc]
    def NOR(pattern1, pattern2, *patterns)
      NOT(OR(pattern1, pattern2, *patterns))
    end

    # @param pattern1 [Proc, Method, #===]
    # @param pattern2 [Proc, Method, #===]
    # @return [Proc]
    def XOR(pattern1, pattern2)
      patterns = [pattern1, pattern2].freeze
      Buildable.validate_patterns(*patterns)

      product = ->v {
        patterns.one? { |pattern| pattern === v }
      }
      Buildable.set_inspect(name: 'XOR', product: product, arguments: patterns)

      product
    end

    # @param pattern [Proc, Method, #===]
    # @return [Proc]
    def NOT(pattern)
      Buildable.validate_patterns(pattern)

      product = ->v { !(pattern === v) }

      Buildable.set_inspect(name: 'NOT', product: product, arguments: [pattern])

      product
    end

    # @param obj [#==]
    # @return [Proc]
    def EQ(obj)
      ->v { obj == v }.tap do |product|
        Buildable.set_inspect(name: 'EQ', product: product, arguments: [obj])
      end
    end

    # @param obj [#equal?]
    # @return [Proc]
    def SAME(obj)
      ->v { obj.equal?(v) }.tap do |product|
        Buildable.set_inspect(name: 'SAME', product: product, arguments: [obj])
      end
    end

    # @param message1 [Symbol, String, #to_sym]
    # @param messages [Array<Symbol, String, #to_sym>]
    # @return [Proc]
    def CAN(message1, *messages)
      messages = (
        begin
          [message1, *messages].map(&:to_sym).freeze
        rescue NoMethodError
          raise ArgumentError
        end
      )

      product = ->v {
        messages.all? { |message|
          begin
            v.respond_to?(message)
          rescue NoMethodError
            false
          end
        }
      }

      Buildable.set_inspect(name: 'CAN', product: product, arguments: messages)

      product
    end

    # @param pattern1 [Proc, Method, #===]
    # @param patterns [Array<Proc, Method, #===>]
    # @return [Proc]
    def QUIET(pattern1, *patterns)
      patterns = [pattern1, *patterns].freeze
      Buildable.validate_patterns(*patterns)

      product = ->v {
        patterns.all? { |pattern|
          begin
            pattern === v
          rescue Exception
            false
          else
            true
          end
        }
      }

      Buildable.set_inspect(name: 'QUIET', product: product, arguments: patterns)

      product
    end

    # @param mod [Module]
    # @param pattern [Proc, Method, #===]
    # @return [Proc]
    def RESCUE(mod, pattern)
      Buildable.validate_patterns(pattern)
      raise ArgumentError unless Module === mod

      product = ->v {
        begin
          pattern === v
          false
        rescue mod
          true
        rescue Exception
          false
        end
      }

      Buildable.set_inspect(name: 'RESCUE', product: product, arguments: [mod, pattern])

      product
    end

    # @param name [Symbol, String, #to_sym]
    # @param pattern [Proc, Method, #===]
    # @return [Proc]
    def SEND(name, pattern)
      name = (
        begin
          name.to_sym
        rescue NoMethodError
          raise ArgumentError
        end
      )
      Buildable.validate_patterns(pattern)

      product = ->v {
        v.__send__(name, pattern)
      }

      Buildable.set_inspect(name: 'SEND', product: product, arguments: [name, pattern])

      product
    end

    ANYTHING = ->_v { true }
    Buildable.set_inspect(name: 'ANYTHING', product: ANYTHING, arguments: [])
    private_constant :ANYTHING

    # @return [ANYTHING]
    def ANYTHING
      ANYTHING
    end

    BOOLEAN = OR(SAME(true), SAME(false))
    private_constant :BOOLEAN

    # @return [BOOLEAN]
    def BOOLEAN
      BOOLEAN
    end
  end
end
