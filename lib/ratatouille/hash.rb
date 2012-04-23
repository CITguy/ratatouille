module Ratatouille

  # Module used to provide Hash-specific validation methods
  #
  # All of the Hash methods perform validation on the *ratifiable_object* defined in 
  # scope of their given block.
  module HashMethods
    # Runs validation in block against object for the given key. It is used to
    # scope its given block to the key value. Useful to reduce the need to
    # explicitly namespace nested keys in *ratifiable_object*.
    #
    # * This method doesn't perform any validation and must be used with a
    #   block to get any use out of it.
    # * Changes *ratifiable_object* to *key value* (original scope will
    #   return on block exit.
    #
    # @param [String, Symbol] key
    # @param [Hash] options
    # @option options [Class] :is_a (nil) 
    #   Used to ensure that the value of the required key is of the given class.
    #   * Performed before all other validation (if defined).
    #   * Validation will be skipped if option not defined.
    # @option options [String, Symbol] :name (key.to_s)
    #   Name of ratifiable_object for use with validation error messages.
    # @option options [Boolean] :required (false) 
    #   Ensure that ratifiable_object has the given key
    def given_key(key, options={}, &block)
      options[:name] = options.fetch(:name, (Symbol === key ? ":#{key}" : key.to_s) )

      parse_options(options)

      unless @unwrap_block == true
        # WRAPPED VALIDATION
        if @required == true
          unless @ratifiable_object.has_key?(key)
            validation_error("Missing key #{key.inspect}")
            return
          end
        end
      end

      if @ratifiable_object.has_key?(key)
        unless @unwrap_block == true
          # WRAPPED VALIDATION
          unless @is_a.nil?
            unless @is_a === @ratifiable_object[key]
              validation_error("key value is not of type #{@is_a}")
              return
            end
          end
        end

        if block_given?
          child_object = Ratatouille::Ratifier.new(@ratifiable_object[key], options, &block)
          @errors[key] = child_object.errors unless child_object.valid?
        end
      end
    rescue Exception => e
      validation_error("#{e.message}")
    end#given_key


    # Perform validation on a single key that must be present in the Hash to validate. 
    # Otherwise, an error will be added.
    #
    # * Eliminates the need to perform given_key methods within a required_keys block.
    # * Evaluates an optional block in context of key value (same as given_key)
    #
    # @param key Required Key
    # @param [Hash] options
    # @option options [Class] :is_a (nil) 
    #   Used to ensure that the value of the required key is of the given class.
    #   * Performed before all other validation (if defined).
    #   * Validation will be skipped if option not defined.
    # @option options [Boolean] :required (true) Used to call given_key.
    # @return [void]
    def required_key(key, options={}, &block)
      options[:required] = true
      # Pass on processing to given_key with :required => true option
      given_key(key, options, &block)
    rescue Exception => e
      validation_error("#{e.message}")
    end


    # Provide a list of keys that must be present in the Hash to validate. 
    # Otherwise, an error will be added.
    #
    # * block is optional
    #
    # *NOTE:* Due to the addition of the optional hash in 1.3.0, required\_keys has been modified 
    # considerably and will break compatibility with previous versions of Ratatouille code.
    #
    # @example pre 1.3.0 vs 1.3.0+
    #   # Old Way
    #   required_keys(:foo, :bar) { validation_here }
    #   # New Way
    #   required_keys(:key_list => [:foo, :bar]) { validation_here }
    #
    # @param [Hash] options
    # @option options [Array] :key_list ([]) Required Keys
    # @option options [Boolean] :unwrap_block (false) 
    #   Perform block validation only -- skip required_keys validation logic.
    #   Useless unless block provided
    # @return [void]
    def required_keys(options={}, &block)
      parse_options(options)

      unless @unwrap_block == true
        req_keys = options.fetch(:key_list, [])

        # Wrapped Validation
        common_keys = (@ratifiable_object.keys & req_keys)

        if @ratifiable_object.empty?
          validation_error("Cannot find required keys")
          return
        end

        if req_keys.nil? || req_keys.empty?
          validation_error("No required keys given to compare against.")
          return
        end

        unless common_keys.size == req_keys.size
          (req_keys - common_keys).each do |missed| 
            validation_error("Missing #{missed.inspect}")
          end
          return
        end
      end

      instance_eval(&block) if block_given?
    rescue Exception => e
      validation_error("#{e.message}")
    end#required_keys


    # Provide a list of keys to choose from and a choice size. 
    # When the Hash does not contain at least 'choice_size' keys of the key 
    # list provided, an error will be added.
    #
    # *NOTE:* Due to the addition of the optional hash in version 1.3.0, choice\_of has been modified 
    # considerably and will break compatibility with previous versions of Ratatouille code.
    #
    # @example pre 1.3.0 vs 1.3.0+
    #   # Old Way
    #   choice_of(1, :foo, :bar) { validation_here }
    #   # New Way
    #   choice_of(:key_list => [:foo, :bar]) { validation_here }
    #
    #   # Old Way
    #   choice_of(2, :foo, :bar, :biz) { validation_here }
    #   # New Way
    #   choice_of(:choice_size => 2, :key_list => [:foo, :bar, :biz]) { validation_here }
    #
    # @param [Hash] options
    # @option options [Integer] :choice_size (1) Number of choices required
    # @option options [Array] :key_list ([]) Keys to choose from
    # @option options [Boolean] :unwrap_block (false) 
    #   Perform block validation only -- skip choice_of validation logic.
    #   Useless unless block provided
    # @return [void]
    def choice_of(options={}, &block)
      parse_options(options)

      unless @unwrap_block == true
        choice_size = options.fetch(:choice_size, 1)
        key_list = options.fetch(:key_list, [])

        # Wrapped Validation
        if key_list.nil? || key_list.empty?
          validation_error("choice_of requires a key list to choose from")
          return
        end
        key_list.flatten!

        # I can work with a non-zero integer or any object that responds
        case choice_size
        when Integer
          unless choice_size > 0
            validation_error("choice_of requires a positive integer for choice size")
            return
          end
        else
          unless choice_size.respond_to?(:to_i)
            validation_error("choice_of requires an object that responds to :to_i for choice size")
            return
          end
          choice_size = choice_size.to_i
        end

        unless choice_size > 0
          validation_error("choice size for choice_of must be positive non-zero number")
          return
        end

        unless key_list.size > choice_size
          validation_error("Key list size for 'choice_of' should be larger than choice size. Consider using required_keys instead.")
          return
        end
        
        common_keys = (@ratifiable_object.keys & key_list)
        unless common_keys.size == choice_size
          choices = key_list.collect{|a| 
            case a
            when Symbol then ":#{a}"
            when String then "#{a}"
            end
          }
          validation_error("Require #{choice_size} of the following: #{choices.join(', ')}")
          return
        end
      end

      instance_eval(&block) if block_given?
    rescue Exception => e
      validation_error("#{e.message}")
    end#choice_of
  end#HashMethods

end
