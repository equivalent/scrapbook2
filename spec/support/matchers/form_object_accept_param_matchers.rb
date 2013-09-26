# FormObject should accept parameter mather
#
#    it{ document_form.should be_able_to_set_param(:document_name_id).on(:document) }
#    it{ document_form.should be_able_to_set_param(:document_name_id).on(:document_content, :content) }
#
# matcher expects that form object have a method `set` which set record
# attribute values
#
RSpec::Matchers.define :be_able_to_set_param do |expected_param|

  chain :on do |resource_sym, method_name_sym = nil|
    raise "Argument for chain method must be a symbol" unless resource_sym.is_a? Symbol
    @resource_sym = resource_sym
    @method_name_sym = (method_name_sym || expected_param).to_sym
  end

  match do |form_object|
    raise "Argument must be a symbol" unless expected_param.is_a? Symbol
    raise "Matcher require chain method 'on'" unless @resource_sym

    if form_object.respond_to?(@resource_sym) and form_object.send(@resource_sym).respond_to?(@method_name_sym)
      form_object.set({expected_param => 123})
      form_object.send(@resource_sym).send(@method_name_sym) == 123
    else
      false
    end
  end

  failure_message_for_should do |actual|
    "Expected form object to be able to set #{expected_param.to_s} "+
      "on #{@resource_sym.to_s} #{@method_name_sym.to_s}."
  end

  failure_message_for_should_not do |actual|
    "Expected form object not to be able to set #{expected_param.to_s} " +
      "on #{@resource_sym.to_s} #{@method_name_sym.to_s}."
  end
end
