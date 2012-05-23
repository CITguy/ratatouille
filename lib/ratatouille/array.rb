module Ratatouille

  # Module used to provide Array-specific validation methods
  module ArrayMethods
    
    # Iterator method to encapsulate validation
    #
    # @note Method will NOT work without a block
    # @param [Hash] options 
    #   Accepts global options in addition to the following:
    # @option options [Hash] :name (array_item)
    #   Name each ratifiable object for use in validation message.
    # @return [void]
    def ratify_each(options={}, &block)
      parse_options(options)

      unless @skip
        if block_given?
          @ratifiable_object.each_with_index do |obj, i|
            options[:name] = options.fetch(:name, "array_item")
            child_object = Ratatouille::Ratifier.new(obj, options, &block)
            @errors["/"] << child_object.errors unless child_object.valid?
          end
        end
      end#skip
    end#ratify_each


    # Define Minimum Length of Array
    # 
    # @param [Integer] min_size
    # @param [Hash] options
    # @option options [Boolean] :unwrap_block (false)
    #   Perform block validation only -- skip min_length validation logic.
    #   Useless unless block provided
    # @return [void]
    def min_length(min_size=0, options={}, &block)
      return length_between(min_size, nil, options, &block)
    rescue Exception => e
      validation_error("#{e.message}")
    end#min_length


    # Define Maximum Length of Array
    #
    # @param [Integer] max_size
    # @param [Hash] options
    # @option options [Boolean] :unwrap_block (false)
    #   Perform block validation only -- skip max_length validation logic.
    #   Useless unless block provided
    # @return [void]
    def max_length(max_size=0, options={}, &block)
      return length_between(0, max_size, options, &block)
    rescue Exception => e
      validation_error("#{e.message}")
    end#max_length


    # Define length range of Array (inclusive)
    #
    # @param [Integer] min_size
    # @param [Integer] max_size
    # @param [Hash] options
    # @option options [Boolean] :unwrap_block (false)
    #   Perform block validation only -- skip length_between validation logic.
    #   Useless unless block provided
    # @return [void]
    def length_between(min_size=0, max_size=nil, options={}, &block)
      parse_options(options)

      unless @skip == true
        unless @unwrap_block == true
          # Minimum Length Validation
          unless min_size.to_i >= 0
            validation_error("min_length must be a number greater than or equal to 0")
            return
          end

          unless @ratifiable_object.size >= min_size.to_i
            validation_error("length must be #{min_size} or more") 
            return
          end

          # Maximum Length Validation
          unless max_size.nil?
            unless max_size.to_i >= 0
              validation_error("max_size must be a number greater than or equal to 0")
              return
            end

            if @ratifiable_object.size > max_size.to_i
              validation_error("length must be less than #{max_size.to_i}")
              return
            end

            unless max_size > min_size
              validation_error("max_size must be greater than min_size")
              return
            end
          end
        end#unwrap_block

        instance_eval(&block) if block_given?
      end#skip
    rescue Exception => e
      validation_error("#{e.message}")
    end#length_between

  end#ArrayMethods

end#module
