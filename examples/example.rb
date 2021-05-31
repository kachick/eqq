# coding: us-ascii
# frozen_string_literal: true

$VERBOSE = true

require_relative '../lib/validation'

class Person
  include Validation

  attr_accessor_with_validation :name, String
  attr_accessor_with_validation :id, OR(nil, AND(Integer, 1..100))
end

person = Person.new
#~ person.name = 8  #=> error
person.name = 'Ken'
#~ person.name = nil  #=> error
p person

person.id = nil
#~ person.id = 'fail' #=> error
#~ person.id = 101 #=> error
#~ person.id = 99.9 #=> error
person.id = 100
p person
