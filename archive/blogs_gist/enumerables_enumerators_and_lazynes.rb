require 'pry'
require 'forwardable'

class Membership
  attr_accessor :type, :owner

  def free?
    type == 'free'
  end

  def paid?
    type == 'paid'
  end

  def unassigned?
    owner.nil?
  end

  # purely for debugging purpose
  def to_s
    "I'm a Membership type=#{type} and I'm #{unassigned? ? 'unassigned' : 'assigned'}"
  end
end

mfu = Membership.new.tap { |m| m.type = 'free'; m.owner = nil }
mfa = Membership.new.tap { |m| m.type = 'free'; m.owner = 123 }
mpa = Membership.new.tap { |m| m.type = 'paid' }





puts "\n\n* Basic Enumerable colection class:\n"

class MembershipCollectionV1
  include Enumerable

  def each(*args, &block)
    @members.each(*args, &block)
  end

  def initialize(*members)
    @members = members.flatten
  end

  def free
    self.class.new(select { |m| m.free? })
  end

  def paid
    self.class.new(select { |m| m.paid? })
  end

  def unassigned
    self.class.new(select { |m| m.unassigned? })
  end
end



collection = MembershipCollectionV1.new(mfu, mfa, mpa)

puts "\n#### collection: "
puts collection.class
# MembershipCollectionV1
puts collection.to_a
# I'm a Membership type=free and I'm unassigned
# I'm a Membership type=free and I'm assigned
# I'm a Membership type=paid and I'm unassigned

puts "\n#### collection.free: "
puts collection.free.class
# MembershipCollectionV1
puts collection.free.to_a
# I'm a Membership type=free and I'm unassigned
# I'm a Membership type=free and I'm assigned

puts "\n#### collection.free.unassigned: "
puts collection.free.unassigned.class
# MembershipCollectionV1
puts collection.free.unassigned.to_a
# I'm a Membership type=free and I'm unassigned




puts "\n\n* Custom Collection classes mapping domain:\n"

module MembershipCollectionV3
  module Base
    def self.included(base)
      base.send :attr_reader, :members
      base.include Enumerable
    end

    def initialize(*members)
      @members = members.flatten
    end
  end

  class Free
    include Base

    def each
      @members.each do |m| yield m if m.free? end
    end

    def unassigned
      Unassigned.new(to_a)
    end
  end

  class Unassigned
    include Base

    def each
      @members.each do |m|  yield m if m.unassigned? end
    end
  end
end


free_collection = MembershipCollectionV3::Free.new(mfu,mfa,mpa)

puts "All members init"
puts free_collection.members
# => [I'm a Membership type=free and I'm unassigned, I'm a Membership type=free and I'm assigned, I'm a Membership type=paid and I'm unassigned]
puts "\n"

puts "collections upon Free enumeration"
puts free_collection.to_a
# => [I'm a Membership type=free and I'm unassigned, I'm a Membership type=free and I'm assigned]
puts "\n"

puts "collection upon Free  enumeration upon Unnassigned enumeration "
puts free_collection.unassigned.to_a
# => [I'm a Membership type=free and I'm unassigned]
puts "\n"


(1..10).to_a
# => [1,2,3,4,5,6,7,8,9]
(1..10).select {|x| x.odd?}
# => [1,2,3,4,5,6,7,8,9] => [1, 3, 5, 7, 9]
(1..10).select {|x| x.odd?}.select{|y| y > 5 }
# => [1,2,3,4,5,6,7,8,9] => [1, 3, 5, 7, 9]  => [7, 9]


(1..10).lazy
# => #<Enumerator::Lazy: 1..10>
(1..10).select {|x| x.odd?}
# #<Enumerator::Lazy: #<Enumerator::Lazy: 1..10>:select> :w
(1..10).lazy.select {|x| x.odd?}.select{|y| y > 5 }
#<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator::Lazy: 1..10>:select>:select>

(1..10).lazy.select {|x| x.odd?}.select{|y| y > 5 }.to_a
# 1 => 1 => nope
# 2 => nope
# 3 => 3 => nope
# 4 => nope
# 5 => 5 => nope
# 6 => nope
# 7 => 7 => 7 => [7]
# 8 => nope
# 9 => 9 => 9 => [7,9]
# 10 => nope
#
# end result => [7,9]

# http://ruby-doc.org/core-2.0.0/Enumerator/Lazy.html#method-i-lazy

(1..Float::INFINITY).lazy.select {|x| x.odd?}.select{|y| y > 5 }.first(8)
# => [7, 9, 11, 13, 15, 17, 19, 21]


# * https://www.sitepoint.com/implementing-lazy-enumerables-in-ruby/
# * http://patshaughnessy.net/2013/4/3/ruby-2-0-works-hard-so-you-can-be-lazy


puts "\n\n## Demonstrating Lazynes\n------------------\n"

module MembershipCollectionV4
  module Base
    extend Forwardable
    def_delegators :each, :first, :to_a, :map

    def self.included(base)
      base.send :attr_reader, :enum
    end

    def initialize(enum)
      @enum = enum
    end
  end

  class Constructor
    include Base

    def each
      enum.map do |raw_m|
        puts "0000 !!!" # our sophisticated debugging
        Membership
          .new
          .tap { |m| m.type  = raw_m.fetch(:type) }
          .tap { |m| m.owner = raw_m.fetch(:owner) }
      end
    end

    def free
      Free.new(each)
    end
  end

  class Free
    include Base

    def each
      enum.select do |m|
        puts "AAAAA !!!" # our sophisticated debugging
        m.free?
      end
    end

    def unassigned
      Unassigned.new(each)
    end
  end

  class Unassigned
    include Base

    def each
      enum.select do |m|
        puts "BBBBB !!!" # our sophisticated debugging
        m if m.unassigned?
      end
    end
  end
end

data = [
  { type: 'paid', owner: nil },
  { type: 'paid', owner: nil },
  { type: 'free', owner: 123 },
  { type: 'paid', owner: nil },
  { type: 'free', owner: 456 },
  { type: 'free', owner: nil },
  { type: 'free', owner: 678 },
  { type: 'free', owner: nil },
  { type: 'paid', owner: nil },
]

enumerator = data.to_enum # regullar collection (e.g. 100 rows from DB query)
#<Enumerator: [{:type=>"free", :owner=>123}, .....]:each> 

lazy_enum = data.lazy  # API stream from socket connection, or dictionary with 10_000_000 lines
# => #<Enumerator::Lazy: [{:type=>"free", :owner=>123}, {:type=>"free", :owner=>nil}, {:type=>"paid", :owner=>nil}]> 

puts "\n\n* Running Enumerator:\n"
unassigned_1 =  MembershipCollectionV4::Constructor.new(enumerator).free.unassigned
puts unassigned_1.first(2)
# 0000 !!!
# 0000 !!!
# 0000 !!!
# 0000 !!!
# 0000 !!!
# 0000 !!!
# 0000 !!!
# 0000 !!!
# 0000 !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# AAAAA !!!
# BBBBB !!!
# BBBBB !!!
# BBBBB !!!
# BBBBB !!!
# BBBBB !!!
# I'm a Membership type=free and I'm unassigned
# I'm a Membership type=free and I'm unassigned

puts "\n\n* Running Lazy Enumerator:\n"
unassigned_2 =  MembershipCollectionV4::Constructor.new(lazy_enum).free.unassigned

puts unassigned_2.first(2)
# 0000 !!!
# AAAAA !!!
# 0000 !!!
# AAAAA !!!
# 0000 !!!
# AAAAA !!!
# BBBBB !!!
# 0000 !!!
# AAAAA !!!
# 0000 !!!
# AAAAA !!!
# BBBBB !!!
# 0000 !!!
# AAAAA !!!
# BBBBB !!!
# 0000 !!!
# AAAAA !!!
# BBBBB !!!
# 0000 !!!
# AAAAA !!!
# BBBBB !!!
# I'm a Membership type=free and I'm unassigned
# I'm a Membership type=free and I'm unassigned



