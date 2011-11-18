require 'spec_helper'

describe "KeyStruct" do

  it "creates a class using KeyStruct.accessor" do
    Class.should === KeyStruct.accessor(:a, :b, :c => 3)
  end

  it "creates a class using KeyStruct.reader" do
    Class.should === KeyStruct.reader(:a, :b, :c => 3)
  end

  it "creates a class using KeyStruct[]" do
    Class.should === KeyStruct[:a, :b, :c => 3]
  end

  it "[] should be an alias for accessor" do
    KeyStruct.method(:[]).should == KeyStruct.method(:accessor)
  end

  context "reader" do
    before(:all) do 
      @klass = KeyStruct.reader(:a, :b, :c => 3)
    end

    it "provides getters" do
      @klass.instance_methods.should include(:a)
      @klass.instance_methods.should include(:b)
      @klass.instance_methods.should include(:c)
    end

    it "does not provide setters" do
      @klass.instance_methods.should_not include(:"a=")
      @klass.instance_methods.should_not include(:"b=")
      @klass.instance_methods.should_not include(:"c=")
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

  context "accessor" do
    before(:all) do 
      @klass = KeyStruct.accessor(:a, :b, :c => 3)
    end

    it "provides getters" do
      @klass.instance_methods.should include(:a)
      @klass.instance_methods.should include(:b)
      @klass.instance_methods.should include(:c)
    end

    it "provides setters" do
      @klass.instance_methods.should include(:"a=")
      @klass.instance_methods.should include(:"b=")
      @klass.instance_methods.should include(:"c=")
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

    it "getters return initial argument values" do
      reader = @klass.new(:a => 1)
      reader.a.should == 1
      reader.b.should be_nil
      reader.c.should == 3
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
