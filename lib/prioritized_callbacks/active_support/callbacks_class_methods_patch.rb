module PrioritizedCallbacks
  module ActiveSupport
    module CallbacksClassMethodsPatch
      def set_callbacks_order(name, order)
        chain = get_callbacks(name)
        raise ArgumentError, "Callbacks for #{name} are not defined" unless chain
        set_callbacks name, chain.copy_with_new_order(order)
      end
    end
  end
end