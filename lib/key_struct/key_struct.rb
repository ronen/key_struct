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

  class Base
    include Comparable

    def initialize(args={})
      args = self.class.defaults.merge(args)
      self.class.keys.each do |key|
        instance_variable_set("@#{key}".to_sym, args.delete(key))
      end
      raise ArgumentError, "Invalid argument(s): #{args.keys.map(&:inspect).join(' ')} -- KeyStruct accepts #{self.class.keys.map(&:inspect).join(' ')}" if args.any?
    end

    def ==(other)
      self.class.keys.all?{|key| other.respond_to?(key) and self.send(key) == other.send(key)}
    end

    def <=>(other)
      self.class.keys.each do |key|
        cmp = (self.send(key) <=> other.send(key))
        return cmp unless cmp == 0
      end
      0
    end

    def to_hash
      Hash[*self.class.keys.map{ |key| [key, self.send(key)]}.flatten(1)]
    end

    def to_s
      "[#{self.class.display_name} #{self.class.keys.map{|key| "#{key}:#{self.send(key)}"}.join(' ')}]"
    end

    def inspect
      "<#{self.class.display_name}:0x#{self.object_id.to_s(16)} #{self.class.keys.map{|key| "#{key}:#{self.send(key).inspect}"}.join(' ')}>"
    end

    def self.display_name
      self.name || "KeyStruct.#{access}"
    end
  end


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
    defaults = (Hash === keys.last) ? keys.pop.dup : {}
    keys += defaults.keys

    Class.new(Base).tap{ |klass|
      klass.class_eval do
        send "attr_#{access}", *keys
        define_singleton_method(:keys) { keys }
        define_singleton_method(:defaults) { defaults }
        define_singleton_method(:access) { access }
      end
    }
  end

end

