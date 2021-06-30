module PrioritizedCallbacks
  module ActiveSupport
    module CallbacksClassMethodsPatch
      def set_callbacks_order(name, order_items)
        chain = get_callbacks(name)
        raise ArgumentError, "Callbacks for #{name} are not defined" unless chain
        set_callbacks name, chain.copy_with_new_order(order_items)
      end

      def append_callbacks_order(name, order_items, options = {})
        chain = get_callbacks(name)
        raise ArgumentError, "Callbacks for #{name} are not defined" unless chain
        order = chain.config[:order]
        insert_pos = order.size
        if (before = options[:before])
          insert_pos = order.index(before)
          raise ArgumentError, "Order '#{before}' is not defined in #{name} callbacks" unless insert_pos
        elsif (after = options[:after])
          insert_pos = order.index(after)
          raise ArgumentError, "Order '#{after}' is not defined in #{name} callbacks" unless insert_pos
          insert_pos += 1
        end
        order.insert insert_pos, *order_items
        set_callbacks_order name, order
      end
    end
  end
end