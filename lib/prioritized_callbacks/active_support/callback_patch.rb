module PrioritizedCallbacks
  module ActiveSupport
    module CallbackPatch
      def self.prepended(base)
        base.singleton_class.prepend ClassMethods
      end

      attr_accessor :priority

      def initialize(name, filter, kind, options, chain_config)
        super
        @priority = options[:priority] || :default
      end

      module ClassMethods
        def build(chain, filter, kind, options)
          if (priority = options[:priority]) && !chain.config[:order].include?(priority)
            raise ArgumentError, "Unknown priority :#{priority} is specified. " +
              "Known priorities are: #{chain.config[:order].inspect}"
          end
          super
        end
      end
    end
  end
end