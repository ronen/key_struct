module KeyStruct

  def self.reader(*keys)
    fetch_key_struct(:reader, keys)
  end

  def self.accessor(*keys)
    fetch_key_struct(:accessor, keys)
  end

  instance_eval do
    alias :[] :accessor
  end

  private

  # for anonymous superclasses, such as
  #
  #    class Foo < KeyStruct[:a, :b]
  #    end
  #
  #  we want to be sure that if the code gets re-executed (e.g. the file
  #  gets loaded twice) the superclass will be the same object otherwise
  #  ruby will raise a TypeError: superclass mismatch.  So keep a cache of
  #  anonymous KeyStructs
  #
  #  But don't reuse the class if it has a name, i.e. if it was assigned to
  #  a constant.  If somebody does
  #
  #     Foo = KeyStruct[:a, :b]
  #     Bar = KeyStruct[:a, :b]
  #
  #  they should get different class definitions, in particular because the
  #  classname is used in #to_s and #inspect
  #
  def self.fetch_key_struct(access, keys)
    @cache ||= {}
    signature = [access, keys]
    @cache.delete(signature) if @cache[signature] and @cache[signature].name
    @cache[signature] ||= define_key_struct(access, keys)
  end

  def self.define_key_struct(access, keys) 
    keys = keys.dup
    defaults = (Hash === keys.last) ? keys.pop : {}
    keys += defaults.keys

    Class.new.tap{ |klass| klass.class_eval do
      include Comparable
      send "attr_#{access}", *keys

      define_singleton_method(:keys) { keys }
      define_singleton_method(:defaults) { defaults }

      define_method(:initialize) do |args={}|
        args = defaults.merge(args)
        keys.each do |key|
          instance_variable_set("@#{key}".to_sym, args.delete(key))
        end
        raise ArgumentError, "Invalid argument(s): #{args.keys.map(&:inspect).join(' ')} -- KeyStruct accepts #{keys.map(&:inspect).join(' ')}" if args.any?
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

