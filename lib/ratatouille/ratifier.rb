module Ratatouille

  # Ratifier  acts as a clean room in which to perform validations.
  class Ratifier
    attr_reader :errors
    attr_reader :ratifiable_object

    # A new instance of Ratifier
    # @param [Hash, Array] obj Object to validate
    # @param [Hash] options
    def initialize(obj, options={}, &block)
      @errors = { "/" => [] }
      @ratifiable_object = obj
      self.name = options[:name]

      parse_options(options)

      case obj
      when Hash  then extend Ratatouille::HashMethods
      when Array then extend Ratatouille::ArrayMethods
      end

      unless @is_a.nil?
        is_a?(@is_a, &block)
      else
        instance_eval( &block ) if block_given?
      end

      cleanup_errors

      @errors.freeze
    end#initialize

    # Alias method (much shorter to type)
    alias :ro :ratifiable_object


    # Name of instance
    #
    # @return [String]
    def name
      @name ||= @ratifiable_object.class.to_s
    end#name


    # Set name of instance
    #
    # @param [String] namein
    # @return [String] name of Ratatouille::Ratifier instance
    def name=(namein)
      case namein
      when String
        @name = namein unless namein.blank?
      end
      @name
    end#name=


    # Add validation error. Useful for custom validations.
    # @param [String] err_in
    # @param [String] context
    # @return [void]
    def validation_error(err_in, context="/" )
      case err_in
      when String
        return if err_in.blank?
        @errors[context] = [] unless @errors[context]
        @errors[context] << err_in
      end
    rescue Exception => e
      @errors[context] << "#{e.message}"
    end#validation_error


    # Does the object pass all validation logic?
    #
    # @return [Boolean]
    def valid?
      @errors.empty?
    end#valid?


    # If there are no errors in the errors hash, empty it out.
    #
    # @return [void]
    def cleanup_errors 
      @errors = {} if errors_array.empty?
    rescue Exception => e
      validation_error("#{e.message}", '/')
    end#cleanup_errors


    # @param [Hash] item Hash to act upon.
    # @return [Array]
    def errors_array(item = @errors)
      all_errs = []

      case item
      when Array
        item.each_with_index do |e,i|
          item_errs = case e
          when Hash, Array then errors_array(e)
          when String then e
          else []
          end

          all_errs << namespace_error_array(item_errs, "#{i}")
          all_errs.flatten!
        end
      when Hash
        item.each_pair do |k,v|
          pair_errs = case v
          when Hash, Array then errors_array(v)
          when String then v
          else []
          end

          all_errs << namespace_error_array(pair_errs, k)
          all_errs.flatten!
        end
      end

      return Array(all_errs)
    end#errors_array


    # Method to check if ratifiable_object matches given class.
    # Will not validate without class.
    #
    # @param [Class] klass
    # @return [void]
    def is_a?(klass=nil, &block)
      if klass.nil?
        validation_error("must provide a Class for is_a?")
        return
      end

      unless klass === @ratifiable_object
        validation_error("object not of type #{klass}")
        return
      end

      instance_eval(&block) if block_given?
    rescue Exception => e
      validation_error("#{e.message}", "/")
    end#is_a?


    # Check if ratifiable object is a TrueClass or FalseClass.
    # Any other class will result in a failed validation.
    #
    # @return [Boolean]
    def is_boolean(options={}, &block)
      parse_options(options)

      unless @skip == true
        unless @unwrap_block == true
          case @ratifiable_object
          when TrueClass, FalseClass 
            # OK to enter block
          else 
            validation_error("#{name} is not a boolean")
            return
          end
        end

        instance_eval(&block) if block_given?
      end
    rescue Exception => e
      validation_error("#{e.message}", "/")
    end#is_boolean?


    # Parse out common options into instance_variables for use within the
    # validation methods defined in various places.
    #
    # @param [Hash] options
    # @option options [Class] :is_a (nil)
    # @option options [Boolean] :required (false)
    # @option options [Boolean] :skip (false)
    # @option options [Boolean] :unwrap_block (false)
    #   Perform block validation only -- skip method validation logic.
    def parse_options(options={})
      if Hash === options
        @is_a =         options.fetch(:is_a, nil)
        @required =     options.fetch(:required, false)
        @skip =         options.fetch(:skip, false)
        @unwrap_block = options.fetch(:unwrap_block, false)
      end
    end#parse_options


    # Override Method Missing for a Ratifier to generate errors for invalid
    # methods called on incorrect objects (hash validation on arrays, etc.)
    # as well as some catch-all methods for boolean validations (is_* and is_not_*)
    def method_missing(id, *args, &block)
      parse_options(args.first)

      unless @skip == true
        case
        when @unwrap_block == true
          # Perform no validation logic
          # Skip to block evaluation
        when id.to_s =~ /^is_not_(.*)$/
          if @ratifiable_object.respond_to?("#{$1}?")
            if @ratifiable_object.send("#{$1}?") == true
              validation_error("#{name} is #{$1}")
              return
            end
          end
        when id.to_s =~ /^is_(.*)$/
          if @ratifiable_object.respond_to?("#{$1}?")
            if @ratifiable_object.send("#{$1}?") == false
              validation_error("#{name} is not #{$1}")
              return
            end
          end
        else
          begin
            super
            return
          rescue Exception => e
            validation_error("#{id} is not supported for the given object (#{@ratifiable_object.class})")
            return e
          end
        end

        instance_eval(&block) if block_given?
      end#skip
    end#method_missing


    # Properly prepend namespace definition to array of errors
    #
    # @param [Array] arr
    # @param [String,Symbol] namespace
    # @return [Array]
    def namespace_error_array(arr=[], namespace="")
      errs_out = Array(arr).collect do |e|
        split_err = e.split("|")

        ctxt, err = "", e
        ctxt, err = split_err if split_err.size == 2

        case namespace
        when String  
          ctxt = "#{namespace}#{ctxt}" unless namespace =~ /^\/.?/
        when Symbol 
          ctxt = ":#{namespace}#{ctxt}"
        end

        if ctxt =~ /^\/.?/
          "#{ctxt}|#{err}" 
        else
          "/#{ctxt}|#{err}"
        end
      end

      return Array(errs_out)
    end#namespace_error_array
  end#Ratifier

end
