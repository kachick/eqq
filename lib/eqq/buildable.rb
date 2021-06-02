# coding: us-ascii
# frozen_string_literal: true

module Eqq
  module Buildable
    extend self

    # @param pattern1 [Proc, Method, #===]
    # @param pattern2 [Proc, Method, #===]
    # @param patterns [Array<Proc, Method, #===>]
    # @return [Proc]
    #   this lambda return true if match all patterns
    def AND(pattern1, pattern2, *patterns)
      ->v {
        [pattern1, pattern2, *patterns].all? { |pattern| pattern === v }
      }
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
      patterns = [pattern1, pattern2, *patterns]
      raise ArgumentError unless patterns.all? { |pattern| Eqq.valid?(pattern) }

      product = ->v {
        patterns.any? { |pattern| pattern === v }
      }

      inspect = "OR(#{patterns.map { |pattern| Eqq.safe_inspect(pattern) }.join(', ')})"

      product.define_singleton_method(:inspect) do
        inspect
      end

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
    # @param patterns [Array<Proc, Method, #===>]
    # @return [Proc]
    def XOR(pattern1, pattern2, *patterns)
      ->v {
        [pattern1, pattern2, *patterns].one? { |pattern| pattern === v }
      }
    end

    # @param pattern1 [Proc, Method, #===]
    # @param pattern2 [Proc, Method, #===]
    # @param patterns [Array<Proc, Method, #===>]
    # @return [Proc]
    def XNOR(pattern1, pattern2, *patterns)
      NOT(XOR(pattern1, pattern2, *patterns))
    end

    # @param pattern [Proc, Method, #===]
    # @return [Proc]
    def NOT(pattern)
      raise ArgumentError, 'wrong object for pattern' unless Eqq.valid?(pattern)

      ->v { !(pattern === v) }
    end

    # A pattern builder.
    # @param obj [#==]
    # @return [Proc]
    def EQ(obj)
      ->v { obj == v }
    end

    # @param obj [#equal?]
    # @return [Proc]
    def SAME(obj)
      ->v { obj.equal?(v) }
    end

    # @param message1 [Symbol, String]
    # @param messages [Array<Symbol, String>]
    # @return [Proc]
    def CAN(message1, *messages)
      messages = begin
        [message1, *messages].map(&:to_sym)
      rescue NoMethodError
        raise ArgumentError
      end

      ->v {
        messages.all? { |message|
          begin
            v.respond_to?(message)
          rescue NoMethodError
            false
          end
        }
      }
    end

    # @param pattern1 [Proc, Method, #===]
    # @param patterns [Array<Proc, Method, #===>]
    # @return [Proc]
    def QUIET(pattern1, *patterns)
      patterns = [pattern1, *patterns]
      unless patterns.all? { |pattern| Eqq.valid?(pattern) }
        raise ArgumentError, 'wrong object for pattern'
      end

      ->v {
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
    end

    # @param mod [Module]
    # @param pattern [Proc, Method, #===]
    # @return [Proc]
    def RESCUE(mod, pattern)
      raise ArgumentError unless Eqq.valid?(pattern)
      raise ArgumentError unless Module === mod

      ->v {
        begin
          pattern === v
          false
        rescue mod
          true
        rescue Exception
          false
        end
      }
    end

    # @param name [Symbol, #to_sym]
    # @param pattern [Proc, Method, #===]
    # @return [Proc]
    def SEND(name, pattern)
      raise InvalidProductError unless Eqq.valid?(pattern)

      ->v {
        v.__send__(name, pattern)
      }
    end

    # @return [BasicObject]
    def ANYTHING
      # BasicObject.=== always passing
      BasicObject
    end

    BOOLEAN = OR(SAME(true), SAME(false))
    private_constant :BOOLEAN

    # @return [BOOLEAN]
    def BOOLEAN
      BOOLEAN
    end
  end
end
