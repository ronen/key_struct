[![Gem Version](https://badge.fury.io/rb/key_struct.svg)](http://badge.fury.io/rb/key_struct)
[![Build Status](https://secure.travis-ci.org/ronen/key_struct.svg)](http://travis-ci.org/ronen/key_struct)
[![Coverage Status](https://img.shields.io/coveralls/ronen/key_struct.svg)](https://coveralls.io/r/ronen/key_struct)

# key_struct

Defines `KeyStruct`, which acts the same as ruby's Struct but the struct's initializer takes keyword args (using a hash, rails-style).  Use it to define a class via:

    Name = KeyStruct[:first, :last]

or as an anonymous base class for your own enhanced struct:

    class Name < KeyStruct[:first, :last]
      def to_s
        "#{@last}, #{@first}"
      end
    end

Then you can create an instance of the class using keywords for the parameters:

    name = Name.new(:first => "Jack", :last => "Ripper")

and you have the usal readers and writers

    name.first            # --> "Jack"
    name.last             # --> "Ripper"
    name.last = "Sprat"
    name.last             # --> "Sprat"
    name.to_s             # --> "Sprat, Jack" for the enhanced class example

## Readers, Writers, and Instance Variables

As per above, the normal behavior is to get readers and writers.  But, by
analogy with `attr_reader` vs `attr_accessor`, you can choose whether you want
read/write or just read:

    Writeable = KeyStruct.accesor(:first, :last)      # aliased as KeyStruct[]
    Readonly = KeyStruct.reader(:first, :last)        # class has readers but not writers

The analogy is not just skin deep: `KeyStruct` actually uses `attr_accessor`
or `attr_reader` to define the accessors for the generated class. This means
that you also get the corresponding instance variables:

    name.instance_variable_get("@last") # --> "Sprat"
    name.instance_variable_set("@last", "Sparrow")
    name.last             # --> "Sparrow"

The instance variables can be useful of course when using KeyStruct to define
an anonymous base class for your own classes, as shown for the `to_s` example
above.

(This is one way that `KeyStruct` differs from ruby's built-in `Struct`:
built-in `Struct` does not define instance variables.)

## Default values

If you leave off a keyword when instantiating, normally the member value is
nil:

    name = Name.new(:first => "Jack")
    name.last             # --> nil

But when you define the class you can specify defaults that will be filled in
by the class initializer. For example:

    Name = KeyStruct[:first, :last => "Doe"]

    name = Name.new(:first => "John")
    name.first            # --> "John"
    name.last             # --> "Doe"

    name = Name.new(:first => "John", :last => "Deere")
    name.first            # --> "John"
    name.last             # --> "Deere"

## Argument Checking

The struct initializer checks for invalid arguments:

    name = Name.new(:this_is_a_typo => "Xavier")  # --> raises ArgumentError

## Comparison

KeyStruct classes define the == operator, which returns true iff all
corresponding struct members are equal (likewise via ==)

    Name.new(:first => "John", :last => "Doe") == Name.new(:first => "John", :last => "Doe")    # --> true
    Name.new(:first => "John", :last => "Doe") == Name.new(:first => "Jane", :last => "Doe")    # --> false

As a convenience when a well-defined ordering is needed, KeyStruct classes
defines the <=> operator and includes the `Comparable` module. The <=>
operator applies <=> to the coresponding struct members sequentially,
returning the first that is non-0. The comparison is performed in the order
the keys were listed in the class definition, so the first key is the primary
comparison key, and so on down the line.  Thus:

    Name = KeyStruct[:first, :last]
    Name.new(:first => "Abigail", :last => "Zither") <=> Name.new(:first => "Zenobia", :last => "Aardvark")           # --> -1

    LastFirst = KeyStruct[:last, :first]
    LastFirst.new(:first => "Abigail", :last => "Zither") <=> LastFirst.new(:first => "Zenobia", :last => "Aardvark") # --> +1

## to_s and inspect

KeyStruct classes define reasonable default `to_s` and `inspect` methods,
along the lines of:

    Name.new(:first => "Jack", :last => "Ripper").to_s      # --> '[Name first:Jack last:Ripper]'
    Name.new(:first => "Jack", :last => "Ripper").inspect   # --> '<Name:0x1234abcd first:"Jack" last:"Ripper">'

## Converting to a hash

KeyStruct classes define a `to_hash` method that returns a hash containing all
members and their values:

    Name.new(:first => "Jack", :last => "Ripper").to_hash   # --> {:first => "Jack", :last => "Ripper")

## Introspection

KeyStruct classes let you examine their definition:

    Name = KeyStruct[:first, :last => "Doe"]
    Name.keys       # --> [ :first, :last ]
    Name.defaults   # --> { :last => "Doe" }

## Installation

Install via:

    % gem install key_struct

or in your Gemfile:

    gem "key_struct"

## Versions

Requires ruby >= 1.9.2.  (Has been tested on MRI 1.9.2 and MRI 1.9.3)

## History

Release Notes:

*   0.4.2 - Bug fix: make class introspection work for derived classes. 
    Restore metaprogramming: inheritance too fragile.
*   0.4.1 - Cache anonymous classes to avoid TypeError: superclass mismatch. 
    Nicer strings for anonymous classes.  Internals change: use base class
    rather than metaprogramming.
*   0.4.0 - Introduce class introspection
*   0.3.1 - Bug fix: to_hash when a value is an array.  Was raising
    ArgumentError for Hash
*   0.3.0 - Introduced to_s and inspect
*   0.2.1 - Bug fix: return false for == with an incompatible object.  Was
    raising NoMethodError
*   0.2.0 - Introduced <=> and to_hash
*   0.1.0 - Introduced ==
*   0.0.1 - Initial version


Past: There was some discussion around this idea in this thread:
http://www.ruby-forum.com/topic/138124 in 2008. 

Future: I hope that this gem will be obviated in future versions of ruby.

## Note on Patches/Pull Requests

*   Fork the project.
*   Make your feature addition or bug fix.
*   Add tests for it.  Make sure that the coverage report (generated
    automatically when you run rspec) is at 100%
*   Send me a pull request.


## Copyright

Released under the MIT License.  See LICENSE for details.
