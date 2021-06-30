module PrioritizedCallbacks
  module ActiveSupport
    module CallbacksClassMethodsPatch
      def set_callbacks_order(name, order_items)
        chain = get_callbacks(name)
        raise ArgumentError, "Callbacks for #{name} are not defined" unless chain
        order_items = order_items.map(&:to_sym)
        set_callbacks name, chain.copy_with_new_order(order_items)
      end

      def append_callbacks_order(name, order_items, options = {})
        chain = get_callbacks(name)
        raise ArgumentError, "Callbacks for #{name} are not defined" unless chain
        order          = chain.config[:order].dup
        insert_pos     = order.size
        order_items    = order_items.map(&:to_sym)
        existing_items = order & order_items
        raise ArgumentError, "Order item(s) #{existing_items.map(&:inspect).join(', ')} already exist for #{name} callbacks" if existing_items.any?
        if (before = options[:before]&.to_sym)
          insert_pos = order.index(before)
          raise ArgumentError, "Order item #{before.inspect} is not defined for #{name} callbacks" unless insert_pos
        elsif (after = options[:after]&.to_sym)
          insert_pos = order.index(after)
          raise ArgumentError, "Order item #{after.inspect} is not defined for #{name} callbacks" unless insert_pos
          insert_pos += 1
        end
        order.insert insert_pos, *order_items
        set_callbacks_order name, order
      end
    end
  end
end