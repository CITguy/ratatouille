# Ratatouille

DSL for validation of complex Hashes

## Installation

Add this line to your application's Gemfile:

    gem 'ratatouille'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ratatouille

## Usage

TODO: Flesh out documentation

### Example
```ruby
  include Ratatouille
  r = ratify({:foo => {:bar => {:biz => "bang"}}}) do
    is_not_empty
    given_key(:foo) do
      given_key(:bar) do
        given_key(:biz) do
          if ratifiable_object == "bang"
            validation_error("should be 'shoot'")
          end
        end
      end
    end
  end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
