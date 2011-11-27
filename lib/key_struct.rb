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
      keyvalues = Hash[*keys.map{|key| (Hash === key) ? key.to_a : [key, nil]}.flatten(2)]
      keys = keyvalues.keys
      send access, *keys
      define_method(:initialize) do |args={}|
        args = keyvalues.merge(args)
        keys.each do |key|
          instance_variable_set("@#{key}", args.delete(key))
        end
        raise ArgumentError, "Invalid argument(s): #{args.keys.map(&:inspect).join(' ')}; KeyStruct accepts #{keys.map(&:inspect).join(' ')}" if args.any?
      end
      define_method(:==) do |other|
        keys.all?{|key| self.send(key) == other.send(key)}
      end
    end
    klass
  end

end
