module Ratatouille

  # Ratifier  acts as a clean room in which to perform validations.
  class Ratifier
    attr_reader :errors
    attr_reader :ratifiable_object

    # A new instance of Ratifier
    # @param [Hash, Array] obj Object to validate
    def initialize(obj, options={}, &block)
      @errors = { "/" => [] }
      @ratifiable_object = obj

      case obj
      when Hash  then extend Ratatouille::HashMethods
      when Array then extend Ratatouille::ArrayMethods
      end

      instance_eval(&block) if block_given?

      cleanup_errors

      @errors.freeze
    end#initialize


    # Add validation error. Useful for custom validations.
    # @param [String] str
    # @param [String] context
    # @return [void]
    def validation_error(str="", context="/")
      return unless str.respond_to?(:to_s)
      return if str.to_s.chomp == ''
      @errors[context] = [] unless @errors[context]
      @errors[context] << str.to_s
    rescue Exception => e
      @errors["/"] << e.message
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
      if errors_array.empty?
        @errors = {}
      end
    rescue Exception => e
      @errors["/"] << e.message
    end#cleanup_errors


    # @param [Hash] hsh Hash to act upon.
    # @return [Array]
    def errors_array(hsh = @errors)
      return [] unless Hash === hsh
      all_errs = []

      hsh.each_pair do |k,v|
        pair_errs = case v
        when Hash then errors_array(v)
        when Array then v
        else []
        end

        nsed_errs = pair_errs.collect do |e|
          split_err = e.split("|")

          ctxt, err = "", e
          ctxt, err = split_err if split_err.size == 2

          case k
          when String  
            ctxt = "#{k}#{ctxt}" unless k == '/'
          when Symbol 
            ctxt = ":#{k}#{ctxt}"
          end

          "/#{ctxt}|#{err}"
        end

        all_errs << nsed_errs
        all_errs.flatten!
      end

      return all_errs
    end#errors_array
  end#Ratifier

end
