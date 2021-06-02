module PrioritizedCallbacks
  module ActiveModel
    module CallbacksPatch

      def define_model_callbacks(*callbacks)
        options = callbacks.extract_options!
        options[:reverse_after] = true

        super *callbacks, options

        callbacks.each do |callback|
          define_singleton_method "set_#{callback}_order" do |*args|
            set_callbacks_order(:"#{callback}", args)
          end
        end
      end

      if ::ActiveModel.version >= Gem::Version.new('6')
        private

        def _define_before_model_callback(klass, callback)
          klass.define_singleton_method("before_#{callback}") do |*args, **options, &block|
            options.assert_valid_keys(:if, :unless, :prepend, :priority)
            set_callback(:"#{callback}", :before, *args, options, &block)
          end
        end

        def _define_around_model_callback(klass, callback)
          klass.define_singleton_method("around_#{callback}") do |*args, **options, &block|
            options.assert_valid_keys(:if, :unless, :prepend, :priority)
            set_callback(:"#{callback}", :around, *args, options, &block)
          end
        end

        def _define_after_model_callback(klass, callback)
          klass.define_singleton_method("after_#{callback}") do |*args, **options, &block|
            options.assert_valid_keys(:if, :unless, :prepend, :priority)
            options[:prepend] = true
            conditional       = ::ActiveSupport::Callbacks::Conditionals::Value.new { |v|
              v != false
            }
            options[:if]      = Array(options[:if]) + [conditional]
            set_callback(:"#{callback}", :after, *args, options, &block)
          end
        end
      end
    end
  end
end
