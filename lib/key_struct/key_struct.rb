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

    defaults = (Hash === keys.last) ? keys.pop : {}
    keys += defaults.keys

    Class.new.tap{ |klass| klass.class_eval do
      include Comparable
      send access, *keys

      define_singleton_method(:keys) { keys }
      define_singleton_method(:defaults) { defaults }

      define_method(:initialize) do |args={}|
        args = defaults.merge(args)
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
        Hash[*keys.map{ |key| [key, self.send(key)]}.flatten(1)]
      end

      define_method(:to_s) do
        "[#{self.class.name} #{keys.map{|key| "#{key}:#{self.send(key)}"}.join(' ')}]"
      end

      define_method(:inspect) do
        "<#{self.class.name}:0x#{self.object_id.to_s(16)} #{keys.map{|key| "#{key}:#{self.send(key).inspect}"}.join(' ')}>"
      end

    end
    }
  end

end

