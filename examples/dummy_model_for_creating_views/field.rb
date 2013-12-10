# This model is just for demo only, please git remove this file before implementing/merging real model
class Field
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :type


  def initialize(options={})
    options.each.each do |key, value|
      self.send("#{key}=", value)
    end

  end

  def self.all
    [new(name: "foo", type: 'Dummy'), new(name: "bar", type: 'Dummy')]
  end

  def self.find(*args)
    new(name: "foo", type: 'Dummy')
  end

  def persisted?
    true
  end

  def new_record?
    false
  end

  def id
    123
  end

  def self.module_name
    OpenStruct.new human: 'Field'
  end
end
