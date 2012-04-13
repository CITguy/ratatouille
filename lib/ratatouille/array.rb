module Ratatouille

  module ArrayMethods
    # @return [void]
    def is_empty(&block)
      unless @ratifiable_object.empty?
        validation_error("Array is not empty")  
        return
      end

      instance_eval(&block) if block_given?
    end#is_empty


    # @return [void]
    def is_not_empty(&block)
      if @ratifiable_object.empty?
        validation_error("Array is empty")
        return
      end

      instance_eval(&block) if block_given?
    end#is_not_empty


    # Define Minimum Length of Array
    # 
    # @param [Integer] min_size
    # @return [void]
    def min_length(min_size=0, &block)
      unless min_size =~ /\d+/
        validation_error("min_length argument must be an Integer")
        return
      end

      unless @ratifiable_object.size >= min_size
        validation_error("Array length must be #{size} or more") 
        return
      end

      instance_eval(&block) if block_given?
    end#min_length


    # Define Maximum Length of Array
    #
    # @param [Integer] min_size
    # @return [void]
    def max_length(max_size=0, &block)
      unless max_size =~ /\d+/
        validation_error("max_length argument must be an Integer")
        return
      end

      if @ratifiable_object.size > max_size
        validation_error("Array length must be less than #{size}")
        return
      end

      instance_eval(&block) if block_given?
    end#max_length


    # Define length range of Array (inclusive)
    #
    # @param [Integer] min_size
    # @param [Integer] max_size
    # @return [void]
    def length_between(min_size=0, max_size=nil, &block)
      unless min_size =~ /\d+/
        validation_error("min_size must be an integer")
        return
      end

      array_size = @ratifiable_object.size
      unless array_size >= min_size
        validation_error("Array length must be #{min_size} or more")
        return
      end

      unless max_size.nil?
        unless max_size =~ /\d+/
          validation_error("max_size must be an integer")
          return
        end

        unless max_size >= min_size
          validation_error("max_size must be greater than or equal to min_size")
          return
        end

        unless array_size <= max_size
          validation_error("Array length must be #{max_size} or less")
          return
        end
      end

      instance_eval(&block) if block_given?
    end#length_between
  end#ArrayMethods

end
