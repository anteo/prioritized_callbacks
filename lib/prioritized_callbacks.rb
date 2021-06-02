require 'prioritized_callbacks/version'
require 'prioritized_callbacks/active_support/callbacks_class_methods_patch'
require 'prioritized_callbacks/active_support/callback_chain_patch'
require 'prioritized_callbacks/active_support/callback_patch'
require 'prioritized_callbacks/callback_list'

ActiveSupport::Callbacks::ClassMethods.prepend PrioritizedCallbacks::ActiveSupport::CallbacksClassMethodsPatch
ActiveSupport::Callbacks::Callback.prepend PrioritizedCallbacks::ActiveSupport::CallbackPatch
ActiveSupport::Callbacks::CallbackChain.prepend PrioritizedCallbacks::ActiveSupport::CallbackChainPatch

if defined?(ActiveModel)
  require 'prioritized_callbacks/active_model/callbacks_patch'
  ActiveModel::Callbacks.prepend PrioritizedCallbacks::ActiveModel::CallbacksPatch
end
