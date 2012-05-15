require 'spec_helper'

shared_examples "a keystruct" do |method|

  context "basic" do

    before(:each) do
      @klass = KeyStruct.send(method, :a, :b, :c => 3)
    end

    it "creates a class" do
      Class.should === @klass
    end

    it "should instrospect keys" do
      @klass.keys.should == [:a, :b, :c]
    end

    it "should instrospect defaults" do
      @klass.defaults.should == {:c => 3}
    end

    it "provides getters" do
      @klass.instance_methods.should include :a
      @klass.instance_methods.should include :b
      @klass.instance_methods.should include :c
    end

    it "initializer accepts all key args" do
      expect { @klass.new(:a => 1, :b => 2, :c => 3) }.should_not raise_error
    end

    it "initializer accepts some key args" do
      expect { @klass.new(:a => 1) }.should_not raise_error
    end

    it "initializer accepts no args" do
      expect { @klass.new }.should_not raise_error
    end

    it "initializer raises error for invalid args" do
      expect { @klass.new(:d => 4) }.should raise_error
    end

    it "getters returns initial/default argument values" do
      reader = @klass.new(:a => 1)
      reader.a.should == 1
      reader.b.should be_nil
      reader.c.should == 3
    end

  end

  context "comparison" do

    before(:each) do 
      @klass = KeyStruct.send(method, :a, :b, :c)
    end

    it "returns true iff all members are ==" do
      @klass.new(:a => 1, :b => 2).should == @klass.new(:a => 1, :b => 2)
      @klass.new(:a => 1, :b => 2).should_not == @klass.new(:a => 1, :b => 3)
    end

    it "returns false for == against incompatible object" do
      @klass.new(:a => 1, :b => 2).should_not == 3
    end

    it "compares based on primary key" do
      @klass.new(:a => 1, :b => 2).should < @klass.new(:a => 2, :b => 2)
    end

    it "compares based on second key if first is equal" do
      @klass.new(:a => 1, :b => 2).should > @klass.new(:a => 1, :b => 1)
    end

    it "compares based on third key if first two are equal" do
      @klass.new(:a => 1, :b => 2, :c => 3).should > @klass.new(:a => 1, :b => 2, :c => 1)
    end

    it "returns zero for <=> if all are equal" do
      (@klass.new(:a => 1, :b => 2) <=> @klass.new(:a => 1, :b => 2)).should == 0
    end

  end

  it "returns hash using to_hash" do
    KeyStruct.send(method, :a => 3, :b => 4).new.to_hash.should == {:a => 3, :b => 4}
  end

  it "returns hash using to_hash when value is array" do
    KeyStruct.send(method, :a => 3, :b => [[1,2], [3,4]]).new.to_hash.should == {:a => 3, :b => [[1,2],[3,4]]}
  end

  it "can handle a default that's an array" do
    expect { KeyStruct.send(method, :a => []) }.should_not raise_error
  end

  context "display as a string" do

    around(:each) do |example|
      PrintMe = @klass = KeyStruct.send(method, :a => 3, :b => "hello")
      example.run
      Object.send(:remove_const, :PrintMe)
    end

    it "should be nice for :to_s" do
      @klass.new.to_s.should == "[PrintMe a:3 b:hello]"
    end

    it "should be detailed for :inspect" do
      @klass.new.inspect.should match /<PrintMe:0x[0-9a-f]+ a:3 b:"hello">/
    end
  end

end

describe "KeyStruct" do

  context "reader" do

    it_behaves_like "a keystruct", :reader

    context "basic" do
      before(:each) do 
        @klass = KeyStruct.reader(:a, :b, :c => 3)
      end

      it "does not provide setters" do
        @klass.instance_methods.should_not include :"a="
        @klass.instance_methods.should_not include :"b="
        @klass.instance_methods.should_not include :"c="
      end
    end

  end

  context "accessor" do
    it_behaves_like "a keystruct", :accessor

    it "[] should be an alias for accessor" do
      KeyStruct.method(:[]).should == KeyStruct.method(:accessor)
    end

    context "basic" do

      before(:each) do 
        @klass = KeyStruct.accessor(:a, :b, :c => 3)
      end

      it "does provides setters" do
        @klass.instance_methods.should include :"a="
        @klass.instance_methods.should include :"b="
        @klass.instance_methods.should include :"c="
      end

      it "setters work as expected" do
        reader = @klass.new(:a => 1)
        reader.b = 2
        reader.c = 4
        reader.a.should == 1
        reader.b.should == 2
        reader.c.should == 4
      end
    end
  end


end
