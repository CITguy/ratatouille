module Ratatouille

  # Module used to provide Array-specific validation methods
  module ArrayMethods
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


    # Define Minimum Length of Array
    # 
    # @param [Integer] min_size
    # @return [void]
    def min_length(min_size=0, &block)
      return unless valid_min_length?(min_size)

      instance_eval(&block) if block_given?
    rescue Exception => e
      validation_error("#{e.message}")
    end#min_length


    # Define Maximum Length of Array
    #
    # @param [Integer] min_size
    # @return [void]
    def max_length(max_size=0, &block)
      return unless valid_max_length?(max_size)

      instance_eval(&block) if block_given?
    rescue Exception => e
      validation_error("#{e.message}")
    end#max_length


    # Define length range of Array (inclusive)
    #
    # @param [Integer] min_size
    # @param [Integer] max_size
    # @return [void]
    def length_between(min_size=0, max_size=nil, &block)
      return unless valid_min_length?(min_size)

      if max_size.nil?
        if min_size == 1
          validation_error("Consider using is_not_empty")
          return
        end
      else
        return unless valid_max_length?(max_size)

        if max_size == 0 && min_size == 0
          validation_error("Consider using is_empty")
          return
        end

        unless max_size > min_size
          validation_error("max_size must be greater than min_size")
          return
        end
      end

      instance_eval(&block) if block_given?
    rescue Exception => e
      validation_error("#{e.message}")
    end#length_between
  private

    # @return [Boolean]
    def valid_min_length?(min_size)
      unless min_size.to_i >= 0
        validation_error("min_length must be a number greater than or equal to 0")
        return false
      end

      unless @ratifiable_object.size >= min_size.to_i
        validation_error("length must be #{min_size} or more") 
        return false
      end
      return true
    rescue Exception => e
      validation_error("#{e.message}")
      return false
    end

    # @return [Boolean]
    def valid_max_length?(max_size)
      unless max_size.to_i >= 0
        validation_error("max_size must be a number greater than or equal to 0")
        return false
      end

      if @ratifiable_object.size > max_size.to_i
        validation_error("length must be less than #{max_size.to_i}")
        return false
      end

      return true
    rescue Exception => e
      validation_error("#{e.message}")
      return false
    end
  end#ArrayMethods

end
