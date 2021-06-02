module PrioritizedCallbacks
  module ActiveSupport
    module CallbackChainPatch
      def initialize(name, config)
        super
        @config[:order] ||= [:default]
        @chain          = PrioritizedCallbacks::CallbackList.new(@config)
      end

      def copy_with_new_order(order)
        new_chain     = dup
        new_config    = config.merge(order: order)
        new_callbacks = @chain.dup
        new_callbacks.instance_variable_set(:@config, new_config)
        new_chain.instance_variable_set(:@config, new_config)
        new_chain.instance_variable_set(:@chain, new_callbacks)
        new_chain
      end
    end
  end
end

