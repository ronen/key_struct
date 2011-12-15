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
    Class.new.class_eval do
      include Comparable
      keyvalues = Hash[*keys.map{|key| (Hash === key) ? key.to_a : [key, nil]}.flatten(2)]
      keys = keyvalues.keys
      send access, *keys
      define_method(:initialize) do |args={}|
        args = keyvalues.merge(args)
        keys.each do |key|
          instance_variable_set("@#{key}".to_sym, args.delete(key))
        end
        raise ArgumentError, "Invalid argument(s): #{args.keys.map(&:inspect).join(' ')}; KeyStruct accepts #{keys.map(&:inspect).join(' ')}" if args.any?
      end
      define_method(:==) do |other|
        keys.all?{|key| other.respond_to?(key) and self.send(key) == other.send(key)}
      end
      define_method(:<=>) do |other|
        keys.each do |key|
          cmp = (self.send(key) <=> other.send(key))
          return cmp unless cmp == 0
        end
        0
      end
      define_method(:to_hash) do
        Hash[*keys.map{ |key| [key, self.send(key)]}.flatten(2)]
      end
      self
    end
  end

end

