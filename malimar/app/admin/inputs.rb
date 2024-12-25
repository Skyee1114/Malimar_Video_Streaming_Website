if defined? ActiveAdmin
  HstoreInput = Class.new Formtastic::Inputs::TextInput   unless defined? HstoreInput
  CitextInput = Class.new Formtastic::Inputs::StringInput unless defined? CitextInput
  UuidInput   = Class.new Formtastic::Inputs::StringInput unless defined? UuidInput
end
