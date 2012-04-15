# Ratatouille 

DSL for validation of complex Hashes

## Travis CI Status: 
[![Build Status](https://secure.travis-ci.org/CITguy/ratatouille.png?branch=master)](http://travis-ci.org/CITguy/ratatouille)

## Installation

Add this line to your application's Gemfile:

    gem 'ratatouille'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ratatouille



## Blocks

All of the given methods accept a block for validation and will not progress into the block if the core method logic does not validate.
However, some methods may be used without a block and validation will progress whether or not the method logic validates.


### ratifiable\_object

Within a block, the ratifiable\_object method provides the object that is to be validated against.
This will change when using *given\_key*.


### name

Within a block, the name method provides the name of the scope. This can be used in your custom validation messages.



## Usage

All of the following methods perform validation on the *ratifiable\_object* defined in scope of the block.


### is\_a?

Method to check if ratifiable\_object matches given class. Will not validate without a given class.


### given\_key

This method is used to scope its given block to the key value. Useful to reduce the need to explicitly namespace nested keys in *ratifiable\_object*.

* **This method doesn't perform any validation and must be used with a block to get any use out of it.**
* Changes *ratifiable\_object* to *key value* (original scope will return on block exit)


#### Syntax

```ruby
    given_key(:foo) do
      # validation for ratifiable_object[:foo]
    end
```

#### Example

See **choice\_of** for an example.


### choice\_of

Meant to be used to validate that X number of given key choices exist in the Hash. 

* Number of Choices must be less than size of key choice array
* Can be used without a block
* Works well with **given\_key()**.


#### Syntax

```ruby
    choice_of(number_of_choices, key_choice_array) do
      # Validation provided number of choices is satisfied
    end
```


#### Example

```ruby
    r = ratify({:foo => "bar", :bar => "biz"}) do
      choice_of(1, :foo, :bar) do
        # Validation, provided :foo OR :bar exists
      end
    end
    r.valid? #=> false (:foo OR :bar must be defined, NOT BOTH)

    r = ratify({:foo => "bar", :bar => "biz"}) do
      choice_of(2, :foo, :bar, :biz) do
        # Validation, provided 2 of the following exist: :foo, :bar, :biz

        given_key(:foo) do
          # in context of ratifiable_object[:foo]
        end

        given_key(:bar) do
          # in context of ratifiable_object[:bar]
        end
      end
    end
    r.valid? #=> true (a choice of 2 items from [:foo, :bar, :biz] is satisfied)

    r = ratify({:foo => "bar", :bar => "biz"}) do
      choice_of(2, :foo, :bar) do
        # Validation ...
      end
    end
    r.valid? #=> false (you might as well use required_keys)
```


### required\_keys

Used to ensure that the list of keys exist in the Hash.

* Block is optional


#### Syntax

```ruby
    # Validate that the keys exist and perform validation if they do
    required_keys(:foo, :bar) do
      # Validation provided that :foo and :bar exist
    end

    # Validate that the keys exist
    required_keys(:foo, :bar)
```


#### Example

```ruby
    r = ratify({:foo => "bar", :bar => "biz"}) do
      required_keys(:foo, :bar)
    end
    r.valid? #=> true

    r = ratify({:foo => "bar"}) do
      required_keys(:foo, :bar)
    end
    r.valid? #=> false
```



### required\_key

Used to ensure given key exists in the Hash.

* Eliminates the need to perform "given\_key" methods within a "required\_keys" block.
* Evaluates an optional block in context of key value (same as given\_key)


#### Syntax

```ruby
    # Validate that the keys exist and perform validation if they do
    required_key(:foo) do
      # Validation provided that :foo exists in Hash
    end

    # Validate that the keys exist
    required_key(:foo)
```



### is\_empty

* Self-explanatory
* Block is optional

```ruby
    r = ratify({:foo => "bar"}) do
      is_empty # validation continues
      is_empty do
        # validation in block is never performed
      end
    end
    r.valid? #=> false

    r = ratify({}) do
      is_empty # validation continues even if not empty
      is_empty do
        # validation continues only if ratifiable_object is empty
      end
    end
    r.valid? #=> true
```


### is\_not\_empty

* Self-explanatory
* Block is optional

```ruby
    r = ratify({:foo => "bar"}) do
      is_not_empty # validation continues even if empty
      is_not_empty do
        # validation continues unless ratifiable_object is empty
      end
    end
    r.valid? #=> true

    r = ratify({}) do
      is_not_empty # validation continues
      is_not_empty do
        # validation in block is never performed
      end
    end
    r.valid? #=> false
```



## Custom Validation

**Return to this section after reading the remaining sections.**

Custom validation can take place using the following methods to generate custom validation logic that cannot be satisfied with the existing methods.

You should use the **validation\_error** method to add your own errors to the Ratifier object.


### validation\_error

Used to insert validation error message into the Ratifier object.

* Scope name prepended to every validation error


#### Syntax

It is also possible to set the context of an error by passing in a second argument. However, it defaults to the root of the current ratifiable\_object ('/').

```ruby
    validation_error("This is an error")
    validation_error("This is an error", "current_context")
```



## Advanced Example

```ruby
    include Ratatouille
    r = ratify({:foo => {:bar => {:biz => "bang"}}}) do
      is_not_empty
      given_key(:foo) do
        validation_error(":foo error")
        given_key(:bar) do
          validation_error(":bar error")
          given_key(:biz) do
            if ratifiable_object == "bang"
              validation_error("should be 'shoot'")
            end
          end
        end
      end
    end
    r.valid? # => false
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
