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



## Information

Specific uses and syntax can be found in the documentation of each module. The information defined
here is common information amongst the entirety of the ratatouille gem.

## Blocks

All of the given methods accept a block for validation and will not progress into the block if the core method logic does not validate.
However, some methods may be used without a block and validation will progress whether or not the method logic validates.


### ratifiable\_object

Within a block, the ratifiable\_object method provides the object that is to be validated against.
This will change when using *given\_key*.


### name

Within a block, the **name** method provides the name of the scope. 
This can be used in your custom validation messages and is already prepended to the beginning
of every validation error.



## Custom Validation

**Return to this section after reading the remaining sections.**

Custom validation can take place using the following methods to generate custom validation logic that cannot be satisfied with the existing methods.

You should use the **validation\_error** method to add your own errors to the Ratifier object.


### validation\_error

Used to insert validation error message into the Ratifier object.

* Scope name prepended to every validation error


#### Syntax

It is also possible to set the context of an error by passing in a second argument. 
However, it defaults to the root of the current ratifiable\_object ('/').

```ruby
    validation_error("This is an error")
    validation_error("This is an error", "current_context")
```



## Universal Options

### :unwrap\_block

This optional key, when set to true, will skip the wrapped validation provided in the called
method and run the validations contained in its given block (if any). This is useful
if previous validation results dictate further validation logic.

#### Example

*A choice of :bar or :biz is required only if :foo is 'green', 
otherwise :bar and :biz should be validated if they are present.*

```ruby
  ratify({:foo => "red"}) do
    required_key(:foo) do
      unwrap_choice = true
      unwrap_choice = false if ratifiable_object == 'green'
    end

    # Because :foo is 'red', choice_of logic will be ignored and the block will be entered.
    choice_of(:key_list => [:bar, :biz], :unwrap_block => unwrap_choice) do
      given_key(:bar) do
        # :bar validation
      end
      given_key(:biz) do
        # :biz validation
      end
    end

    # If :foo were 'green', choice_of logic would be performed before entering the block.
  end
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
