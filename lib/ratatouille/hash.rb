module Ratatouille

  module HashMethods
    # Runs validation in block against object for the given key.
    #
    # @param [String, Symbol] key
    def given_key(key, &block)
      if @ratifiable_object.has_key?(key)
        child_object = Ratatouille::Ratifier.new(@ratifiable_object[key], &block)
        @errors[key] = child_object.errors unless child_object.valid?
      end
    end#given_key


    # @return [void]
    def is_empty(&block)
      unless @ratifiable_object.empty?
        validation_error("Hash is not empty")  
        return
      end

      instance_eval(&block) if block_given?
    end#is_empty


    # @return [void]
    def is_not_empty(&block)
      if @ratifiable_object.empty?
        validation_error("Hash is empty")      
        return
      end

      instance_eval(&block) if block_given?
    end#is_not_empty


    # Provide a list of keys that must be present in the Hash to validate. Otherwise,
    # an error will be added.
    #
    # @param [Array] args Array of symbols and/or strings to denote the required keys
    # @return [void]
    def required_keys(*args, &block)
      req_keys = args.collect{|a| String === a || Symbol === a}
      common_keys = (@ratifiable_object.keys & req_keys)

      unless common_keys.size == req_keys.size
        (req_keys - common_keys).each do |missed| 
          case missed
          when Symbol then validation_error("Missing :#{missed}")
          when String then validation_error("Missing #{missed}")
          end
        end
        return
      end

      instance_eval(&block) if block_given?
    end#required_keys


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
      unless choice_size =~ /\d+/ && choice_size > 0
        validation_error("choice_of requires a positive integer as first argument")
        return
      end
      
      common_keys = (@ratifiable_object.keys & key_list)
      unless common_keys.size == choice_size
        choices = key_list.collect{|a| String === a || Symbol === a}
        validation_error("Require #{choice_size} of the following: #{choices.join(', ')}")
        return
      end

      instance_eval(&block) if block_given?
    end#choice_of
  end#HashMethods

end
