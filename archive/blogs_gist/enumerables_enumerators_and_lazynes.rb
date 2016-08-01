#require 'pry'        # pry gem for debugging
require 'forwardable' # core ruby lib.

# Don't mind this module, it's just for formating output of examples
module Article
  def self.h1(title)
    extended_title = "###### #{title} ######"
    puts "\n\n\n#{extended_title}\n"
    puts "=" * extended_title.length
  end

  def self.example(title)
    puts "\n"
    puts "# #{title}"
    yield
    puts "# ---"
    puts "\n"
  end
end


#------------------------------
Article.h1('Enumerator basics')
#------------------------------

my_array = [1,2,3]

Article.example('my_array.to_enum') do
  puts my_array.to_enum
  # => #<Enumerator: [1, 2, 3]:each>
end

Article.example('my_array.each') do
  puts my_array.each
  # => #<Enumerator: [1, 2, 3]:each>
end


Article.example('How Enumerator is popping values') do
  e = my_array.to_enum

  puts e.next_values
  # => [1]
  puts e.next_values
  # # => [2]

  puts e.next_values
  # => [3]

  begin
    puts e.next_values
    #   StopIteration: iteration reached an end
    #   from (irb):20:in `next_values'
    #   from (irb):20
    #   lets display list of availible methods:
  rescue => exeption
    puts exeption.message
  end

  e.public_methods(false)
  # # => [:each, :each_with_index, :each_with_object, :with_index,
  # :with_object, :next_values, :peek_values, :next, :peek, :feed, :rewind,
  # :inspect, :size]

  e.rewind

  puts e.next_values
  #  => [1]
end


Article.example('Simplest  implementation of custom Enumerator-alike object') do
  class Bar
    def each
      yield 'xxx'
      yield 'yyy'
      yield 'zzz'
    end
  end

  Bar.new.each do |member|
    puts member
  end
  # xxx
  # yyy
  # zzz
end

# -------------------------------
Article.h1('Enumerable basics')
# -------------------------------

class Foo
  include Enumerable

  def each
    yield 'aaa'
    yield 'bbb'
    yield 'ccc'
  end
end

foo = Foo.new

Article.example 'foo.each' do
  foo.each do |member|
    puts member
  end
  # aaa
  # bbb
  # ccc
end

Article.example 'foo.count' do
  puts foo.count
  # => 3
end

Article.example 'foo.to_a' do
  puts foo.to_a.inspect
  # => ["aaa", "bbb", "ccc"]
end

Article.example 'foo.map(&:capitalize)' do
  puts foo.map(&:capitalize).inspect
  # => ["Aaa", "Bbb", "Ccc"]
end

Article.example 'foo.to_enum.next_values' do
  foo_enumerator = foo.to_enum

  puts foo_enumerator.next_values.inspect
  # => ["aaa"]
end

#---------------------------------------------
Article.h1('Simple Enumerable colection class mapping domain')
#---------------------------------------------

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
  alias inspect to_s
end

mfu = Membership.new.tap { |m| m.type = 'free'; m.owner = nil }
mfa = Membership.new.tap { |m| m.type = 'free'; m.owner = 123 }
mpa = Membership.new.tap { |m| m.type = 'paid' }

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

Article.example 'Entire collection' do
  puts collection.class
  # MembershipCollectionV1
  puts collection.to_a
  # I'm a Membership type=free and I'm unassigned
  # I'm a Membership type=free and I'm assigned
  # I'm a Membership type=paid and I'm unassigned
end

Article.example 'Free collection' do
  puts collection.free.class
  # MembershipCollectionV1
  puts collection.free.to_a
  # I'm a Membership type=free and I'm unassigned
  # I'm a Membership type=free and I'm assigned
end

Article.example 'Free Unassigned collection' do
  puts "\n#### collection.free.unassigned: "
  puts collection.free.unassigned.class
  # MembershipCollectionV1
  puts collection.free.unassigned.to_a
  # I'm a Membership type=free and I'm unassigned
end


#---------------------------------------------
Article.h1('Custom Enumerator collection classes mapping domain logic')
#---------------------------------------------

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
      @members.each { |m| yield m if m.free? }
    end

    def unassigned
      Unassigned.new(to_a)
    end
  end

  class Paid
    include Base

    def each
      @members.each { |m| yield m if m.paid? }
    end
  end

  class Unassigned
    include Base

    def each
      @members.each { |m|  yield m if m.unassigned? }
    end
  end
end


free_collection = MembershipCollectionV3::Free.new(mfu,mfa,mpa)
paid_collection = MembershipCollectionV3::Paid.new(mfu,mfa,mpa)

Article.example "All members" do
  puts free_collection.members.inspect
  # => [I'm a Membership type=free and I'm unassigned, I'm a Membership type=free and I'm assigned, I'm a Membership type=paid and I'm unassigned]
end

Article.example "collections upon Free enumeration" do
  puts free_collection.to_a.inspect
  # => [I'm a Membership type=free and I'm unassigned, I'm a Membership type=free and I'm assigned]
end

Article.example "collection upon Free enumeration upon Unnassigned enumeration" do
  puts free_collection.unassigned.to_a.inspect
  # => [I'm a Membership type=free and I'm unassigned]
end

Article.example "collections upon Paid enumeration" do
  puts paid_collection.to_a.inspect
  # => [I'm a Membership type=free and I'm unassigned]
end

Article.example "collections upon Paid enumeration trying to call unassigned" do
  begin
    paid_collection.unassigned.to_a.inspect
    # undefined method `unassigned' for #<MembershipCollectionV3::Paid:0x0000000281d4e8> (NoMethodError)
  rescue NoMethodError
  end
end

# ----------------------------------
Article.h1('What is Lazy Enumerator')
# ----------------------------------

Article.example 'Enumerator' do
  puts '(1..10).to_a'
  puts (1..10).to_a.inspect
  # => [1,2,3,4,5,6,7,8,9]

  puts ""
  puts '(1..10).select {|x| x.odd?}'
  puts (1..10).select {|x| x.odd?}.inspect
  # => [1,2,3,4,5,6,7,8,9] => [1, 3, 5, 7, 9]

  puts ""
  puts '(1..10).select {|x| x.odd?}.select{|y| y > 5 }'
  puts (1..10).select {|x| x.odd?}.select{|y| y > 5 }.inspect
  # => [1,2,3,4,5,6,7,8,9] => [1, 3, 5, 7, 9]  => [7, 9]

  # what's really happening:
  # 1..10 -> to_a -> select -> select
end


Article.example 'Lazy Enumerator' do
  puts '(1..10).lazy'
  puts (1..10).lazy.inspect
  # => #<Enumerator::Lazy: 1..10>

  puts ""
  puts '(1..10).select {|x| x.odd?}'
  puts (1..10).lazy.select {|x| x.odd?}.inspect
  # #<Enumerator::Lazy: #<Enumerator::Lazy: 1..10>:select>

  puts ""
  puts '(1..10).lazy.select {|x| x.odd?}.select{|y| y > 5 }'
  puts (1..10).lazy.select {|x| x.odd?}.select{|y| y > 5 }.inspect
  #<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator::Lazy: 1..10>:select>:select>

  puts ""
  puts '(1..10).lazy.select {|x| x.odd?}.select{|y| y > 5 }.to_a'
  puts (1..10).lazy.select {|x| x.odd?}.select{|y| y > 5 }.to_a.inspect
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

  # what's really happening:
  # 1..10 <- select <- select <- first(5)
end


Article.example 'Lazy Enumerator used in Infinity list' do
  puts (1..Float::INFINITY).lazy.select {|x| x.odd?}.select{|y| y > 5 }.first(8).inspect
  # => [7, 9, 11, 13, 15, 17, 19, 21]
end

# * http://ruby-doc.org/core-2.0.0/Enumerator/Lazy.html#method-i-lazy
# * https://www.sitepoint.com/implementing-lazy-enumerables-in-ruby/
# * http://patshaughnessy.net/2013/4/3/ruby-2-0-works-hard-so-you-can-be-lazy


# ----------------------------------------------------------------
Article.h1 'Domain specific collection object respecting Lazynes'
# ---------------------------------------------------------------

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

Article.example 'passing standard Enumerator to it' do
  enumerator = data.to_enum # regullar collection (e.g. 100 rows from DB query)
  #<Enumerator: [{:type=>"free", :owner=>123}, .....]:each>

  unassigned_1 =  MembershipCollectionV4::Constructor.new(enumerator).free.unassigned
  result = unassigned_1.first(2)
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

  puts "\nResult:"
  puts result
  # I'm a Membership type=free and I'm unassigned
  # I'm a Membership type=free and I'm unassigned
end

Article.example 'passing lazy Enumerator to it' do
  lazy_enum = data.lazy  # API stream from socket connection, or dictionary with 10_000_000 lines
  # => #<Enumerator::Lazy: [{:type=>"free", :owner=>123}, {:type=>"free", :owner=>nil}, {:type=>"paid", :owner=>nil}]> 

  unassigned_2 =  MembershipCollectionV4::Constructor.new(lazy_enum).free.unassigned
  result = unassigned_2.first(2)
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

  puts "\nResult:"
  puts result
  # I'm a Membership type=free and I'm unassigned
  # I'm a Membership type=free and I'm unassigned
end


# ===============================================================================================
# ============================================  OUPUT    ========================================
# ===============================================================================================
#
# ###### Enumerator basics ######
# ===============================
#
# # my_array.to_enum
# #<Enumerator:0x00000003615370>
# # ---
#
#
# # my_array.each
# #<Enumerator:0x00000003615118>
# # ---
#
#
# # How Enumerator is popping values
# 1
# 2
# 3
# iteration reached an end
# 1
# # ---
#
#
# # Simplest  implementation of custom Enumerator-alike object
# xxx
# yyy
# zzz
# # ---
#
#
#
#
# ###### Enumerable basics ######
# ===============================
#
# # foo.each
# aaa
# bbb
# ccc
# # ---
#
#
# # foo.count
# 3
# # ---
#
#
# # foo.to_a
# ["aaa", "bbb", "ccc"]
# # ---
#
#
# # foo.map(&:capitalize)
# ["Aaa", "Bbb", "Ccc"]
# # ---
#
#
# # foo.to_enum.next_values
# ["aaa"]
# # ---
#
#
#
#
# ###### Basic Enumerable colection class ######
# ==============================================
#
# # Entire collection
# MembershipCollectionV1
# I'm a Membership type=free and I'm unassigned
# I'm a Membership type=free and I'm assigned
# I'm a Membership type=paid and I'm unassigned
# # ---
#
#
# # Free collection
# MembershipCollectionV1
# I'm a Membership type=free and I'm unassigned
# I'm a Membership type=free and I'm assigned
# # ---
#
#
# # Free Unassigned collection
#
# #### collection.free.unassigned: 
# MembershipCollectionV1
# I'm a Membership type=free and I'm unassigned
# # ---
#
#
#
#
# ###### Custom Collection classes mapping domain logic ######
# ============================================================
#
# # All members
# [#<Membership:0x00000003612f58 @type="free", @owner=nil>, #<Membership:0x00000003612ee0 @type="free", @owner=123>, #<Membership:0x00000003612e90 @type="paid">]
# # ---
#
#
# # collections upon Free enumeration
# [#<Membership:0x00000003612f58 @type="free", @owner=nil>, #<Membership:0x00000003612ee0 @type="free", @owner=123>]
# # ---
#
#
# # collection upon Free enumeration upon Unnassigned enumeration
# [#<Membership:0x00000003612f58 @type="free", @owner=nil>]
# # ---
#
#
#
#
# ###### What is Lazy Enumerator ######
# =====================================
#
# # Enumerator
# (1..10).to_a
# [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
#
# (1..10).select {|x| x.odd?}
# [1, 3, 5, 7, 9]
#
# (1..10).select {|x| x.odd?}.select{|y| y > 5 }
# [7, 9]
# # ---
#
#
# # Lazy Enumerator
# (1..10).lazy
# #<Enumerator::Lazy: 1..10>
#
# (1..10).select {|x| x.odd?}
# #<Enumerator::Lazy: #<Enumerator::Lazy: 1..10>:select>
#
# (1..10).lazy.select {|x| x.odd?}.select{|y| y > 5 }
# #<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator::Lazy: 1..10>:select>:select>
#
# (1..10).lazy.select {|x| x.odd?}.select{|y| y > 5 }.to_a
# [7, 9]
# # ---
#
#
# # Lazy Enumerator used in Infinity list
# [7, 9, 11, 13, 15, 17, 19, 21]
# # ---
#
#
#
#
# ###### Domain specific collectinion object respecting Lazynes ######
# ====================================================================
#
# # passing standard Enumerator to it
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
#
# Result:
# I'm a Membership type=free and I'm unassigned
# I'm a Membership type=free and I'm unassigned
# # ---
#
#
# # passing lazy Enumerator to it
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
#
# Result:
# I'm a Membership type=free and I'm unassigned
# I'm a Membership type=free and I'm unassigned
# # ---
# a
