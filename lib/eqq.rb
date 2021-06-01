# coding: us-ascii
# frozen_string_literal: true

# Copyright (c) 2011 Kenichi Kamiya
# Forked from https://github.com/kachick/eqq at 2021

module Eqq
  def self.conditionable?(object)
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

  def self.define(&block)
    module_exec(&block)
  end

  module_function

  # A condition builder.
  # @param condition1 [Proc, Method, #===]
  # @param condition2 [Proc, Method, #===]
  # @param conditions [Array<Proc, Method, #===>]
  # @return [Proc]
  #   this lambda return true if match all conditions
  def AND(condition1, condition2, *conditions)
    ->v {
      [condition1, condition2, *conditions].all? { |condition| condition === v }
    }
  end

  # A condition builder.
  # @param condition1 [Proc, Method, #===]
  # @param condition2 [Proc, Method, #===]
  # @param conditions [Array<Proc, Method, #===>]
  # @return [Proc]
  def NAND(condition1, condition2, *conditions)
    NOT(AND(condition1, condition2, *conditions))
  end

  # A condition builder.
  # @param condition1 [Proc, Method, #===]
  # @param condition2 [Proc, Method, #===]
  # @param conditions [Array<Proc, Method, #===>]
  # @return [Proc]
  #   this lambda return true if match a any condition
  def OR(condition1, condition2, *conditions)
    ->v {
      [condition1, condition2, *conditions].any? { |condition| condition === v }
    }
  end

  # A condition builder.
  # @param condition1 [Proc, Method, #===]
  # @param condition2 [Proc, Method, #===]
  # @param conditions [Array<Proc, Method, #===>]
  # @return [Proc]
  def NOR(condition1, condition2, *conditions)
    NOT(OR(condition1, condition2, *conditions))
  end

  # A condition builder.
  # @param condition1 [Proc, Method, #===]
  # @param condition2 [Proc, Method, #===]
  # @param conditions [Array<Proc, Method, #===>]
  # @return [Proc]
  def XOR(condition1, condition2, *conditions)
    ->v {
      [condition1, condition2, *conditions].one? { |condition| condition === v }
    }
  end

  # A condition builder.
  # @param condition1 [Proc, Method, #===]
  # @param condition2 [Proc, Method, #===]
  # @param conditions [Array<Proc, Method, #===>]
  # @return [Proc]
  def XNOR(condition1, condition2, *conditions)
    NOT(XOR(condition1, condition2, *conditions))
  end

  # A condition builder.
  # @param condition [Proc, Method, #===]
  # @return [Proc] A condition invert the original condition.
  def NOT(condition)
    unless Eqq.conditionable?(condition)
      raise TypeError, 'wrong object for condition'
    end

    ->v { !(condition === v) }
  end

  # A condition builder.
  # @param obj [#==]
  # @return [Proc]
  #   this lambda return true if a argument match under #== method
  def EQ(obj)
    ->v { obj == v }
  end

  # A condition builder.
  # @param obj [#equal?]
  # @return [Proc]
  #   this lambda return true if a argument match under #equal? method
  def SAME(obj)
    ->v { obj.equal?(v) }
  end

  # A condition builder.
  # @param message1 [Symbol, String]
  # @param messages [Array<Symbol, String>]
  # @return [Proc]
  #   this lambda return true if a argument respond to all messages
  def CAN(message1, *messages)
    messages = [message1, *messages].map(&:to_sym)

    ->v {
      messages.all? { |message| v.respond_to?(message) }
    }
  end

  # A condition builder.
  # @param condition1 [Proc, Method, #===]
  # @param conditions [Array<Proc, Method, #===>]
  # @return [Proc]
  #   this lambda return true
  #   if face no exception when a argument checking under all conditions
  def QUIET(condition1, *conditions)
    conditions = [condition1, *conditions]
    unless conditions.all? { |c| Eqq.conditionable?(c) }
      raise TypeError, 'wrong object for condition'
    end

    ->v {
      conditions.all? { |condition|
        begin
          condition === v
        rescue Exception
          false
        else
          true
        end
      }
    }
  end

  # A condition builder.
  # @param exception [Exception]
  # @param exceptions [Array<Exception>]
  # @return [Proc]
  #   this lambda return true
  #   if catch any kindly exceptions when a argument checking in a block parameter
  def RESCUE(exception, *exceptions, &condition)
    exceptions = [exception, *exceptions]
    raise ArgumentError unless Eqq.conditionable?(condition)
    raise ArgumentError unless exceptions.all?(Exception)

    ->v {
      begin
        condition.call(v)
        false
      rescue *exceptions
        true
      rescue Exception
        false
      end
    }
  end

  # A condition builder.
  # @param exception [Exception]
  # @return [Proc]
  #   this lambda return true
  #   if catch a specific exception when a argument checking in a block parameter
  def CATCH(exception, &condition)
    raise ArgumentError unless Eqq.conditionable?(condition)
    raise ArgumentError unless exceptions.all?(Exception)

    ->v {
      begin
        condition.call(v)
      rescue Exception => err
        err.instance_of?(exception)
      else
        false
      end
    }
  end

  # A condition builder.
  # @param condition1 [Proc, Method, #===]
  # @param condition2 [Proc, Method, #===]
  # @param conditions [Array<Proc, Method, #===>]
  # @return [Proc]
  #   this lambda return true
  #   if all included objects match all conditions
  def ALL(condition1, condition2, *conditions)
    condition = Eqq.AND(condition1, condition2, *conditions)

    ->list {
      enum = (
        case
        when list.respond_to?(:each_value)
          list.each_value
        when list.respond_to?(:all?)
          list
        when list.respond_to?(:each)
          list.each
        else
          return false
        end
      )

      enum.all?(condition)
    }
  end

  def ANYTHING
    # BasicObject.=== always passing
    BasicObject
  end

  BOOLEAN = OR(SAME(true), SAME(false))

  # A getter for a useful condition.
  # @return [BOOLEAN] "true or false"
  def BOOLEAN
    BOOLEAN
  end
end

require_relative 'eqq/version'
