module Ratatouille

  # Module used to provide Hash-specific validation methods
  module HashMethods
    # Runs validation in block against object for the given key.
    #
    # @param [String, Symbol] key
    # @param [Hash] options
    def given_key(key, options={}, &block)
      options[:name] = options.fetch(:name, (Symbol === key ? ":#{key}" : key.to_s) )

      if @ratifiable_object.has_key?(key) && block_given?
        child_object = Ratatouille::Ratifier.new(@ratifiable_object[key], options, &block)
        @errors[key] = child_object.errors unless child_object.valid?
      end
    rescue Exception => e
      validation_error("#{e.message}")
    end#given_key


    # @return [void]
    def is_empty(&block)
      unless @ratifiable_object.empty?
        validation_error("not empty")  
        return
      end

      instance_eval(&block) if block_given?
    rescue Exception => e
      validation_error("#{e.message}")
    end#is_empty


    # @return [void]
    def is_not_empty(&block)
      if @ratifiable_object.empty?
        validation_error("empty")      
        return
      end

      instance_eval(&block) if block_given?
    rescue Exception => e
      validation_error("#{e.message}")
    end#is_not_empty


    # Provide a list of keys that must be present in the Hash to validate. Otherwise,
    # an error will be added.
    #
    # @param [Array] args Array required keys
    # @return [void]
    def required_keys(*req_keys, &block)
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
          case missed
          when Symbol then validation_error("Missing :#{missed}")
          when String then validation_error("Missing #{missed}")
          when respond_to?(:to_s)
            validation_error("Missing #{missed.to_s}")
          end
        end
        return
      end

      instance_eval(&block) if block_given?
    rescue Exception => e
      validation_error("#{e.message}")
    end#required_keys


    # Perform validation on a key that must be present in the Hash to validate. Otherwise,
    # an error will be added.
    #
    # @param [String,Symbol] req_key Required Key
    # @return [void]
    def required_key(req_key, options={}, &block)
      if req_key.nil?
        validation_error("required_key needs key argument")
        return
      end

      unless @ratifiable_object.has_key?(req_key)
        case req_key
        when Symbol then validation_error("Missing key :#{req_key}")
        when String then validation_error("Missing key #{req_key}")
        when respond_to?(:to_s)
          validation_error("Missing key #{req_key.to_s}")
        end
        return
      end

      given_key(req_key, options, &block) if block_given?
    rescue Exception => e
      validation_error("#{e.message}")
    end


    # Provide a list of keys to choose from and a choice size (default 1). 
    # When the Hash does not contain at least 'choice_size' keys of the key 
    # list provided, an error will be added.
    #
    # @param [Integer] choice_size
    # @param [Array] args 
    #   Array of symbols and/or strings to denote the choices of keys.
    #   All other values are ignored.
    # @return [void]
    def choice_of(choice_size=1, *key_list, &block)
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

      instance_eval(&block) if block_given?
    rescue Exception => e
      validation_error("#{e.message}")
    end#choice_of
  end#HashMethods

end
