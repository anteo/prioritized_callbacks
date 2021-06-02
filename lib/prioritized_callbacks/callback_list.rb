module PrioritizedCallbacks
  class CallbackList < Array
    attr_reader :config

    def initialize(config, callbacks = [])
      @config = config
      super(callbacks)
    end

    def each
      if config[:reverse]
        callbacks = to_a.reverse
        order     = config[:order].reverse
      else
        callbacks = to_a
        order     = config[:order]
      end
      if config[:reverse_after]
        order.each do |priority|
          callbacks.each do |callback|
            yield callback if callback.priority == priority && (callback.kind == :before || callback.kind == :around)
          end
        end
        order.reverse.each do |priority|
          callbacks.each do |callback|
            yield callback if callback.priority == priority && callback.kind == :after
          end
        end
      else
        order.each do |priority|
          callbacks.each do |callback|
            yield callback if callback.priority == priority
          end
        end
      end
    end

    def reverse
      CallbackList.new(config.merge(reverse: true), to_a)
    end
  end
end