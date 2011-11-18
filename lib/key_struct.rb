require "key_struct/version"

module KeyStruct

  def self.reader(*keys)
    define_key_struct(:attr_reader, keys)
  end

  def self.accessor(*keys)
    define_key_struct(:attr_accessor, keys)
  end

  instance_eval do
    alias :[] :accessor
  end

  private

  def self.define_key_struct(access, keys) 
    klass = Class.new
    klass.class_eval do
      send access, *keys
      define_method(:initialize) do |keyvalues={}|
        keyvalues = keyvalues.dup
        keys.each do |key|
          instance_variable_set("@#{key}", keyvalues.delete(key))
        end
        raise ArgumentError, "Invalid argument(s): #{keyvalues.keys.map(&:inspect).join(' ')}; KeyStruct accepts #{keys.map(&:inspect).join(' ')}" if keyvalues.any?
      end
    end
    klass
  end

end
