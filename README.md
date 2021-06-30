# Prioritized ActiveSupport Callbacks

Sometimes, when you build big system with a massive number of plugins, you can realize that you need to prioritize
callbacks in your models or controllers to have full control which callbacks are executed first,
which are executed last despite of the order in which they were initially added.

**WARNING!** Do not use this gem unless you know that's the only way.

## Install

Add the following line to Gemfile:

`gem 'prioritized_callbacks'`

## Compatibility

It is checked against all Rails versions >= 5.0 and Ruby >= 2.7

## Usage

### Using pure ActiveSupport::Callbacks:

```ruby
require 'active_support'
require 'prioritized_callbacks'

class MyClass
  include ActiveSupport::Callbacks
  
  define_callbacks :action, order: [:first, :default, :last]

  set_callback :action, :before do
    puts "I'm called second before action"
  end
  
  set_callback :action, :before, priority: :first do
    puts "I'm called first before action"
  end

  set_callback :action, :before, priority: :last do
    puts "I'm called third before action"
  end
end

MyClass.new.run_callbacks :action do
  puts "Action performed"
end
```

Will output:

```
I'm called first before action
I'm called second before action
I'm called third before action
Action performed
```

Here are two parts to setup:

1) Definition of callbacks priority names and its order:

```ruby
define_callbacks :action, order: [:first, :default, :last]
```

When you define callbacks, you specify the order of callback groups. You can give groups any name, but there is a 
special name `:default` which is used for any callbacks whose priority is not specified.

If you do not specify `:order`, it gets default Rails behaviour and is implicitly set to `[:default]` 

2) Assigning priority name to callback itself:

```ruby
set_callback :action, :before, priority: :first do ... end
```

When you add new callback, you can specify its priority by using name you used in callback definition (see above).
If you don't specify `:priority`, `:default` is assumed.

Callbacks with the same priority are executed in the order how they were added.

### Using ActiveRecord callbacks

```ruby
class Record < ActiveRecord::Base
  
  set_save_order :first, :default, :last
  
  before_save priority: :last do
    # Do something last
  end
  
  before_save :do_first, priority: :first
  
  before_save :do_default
end
```

1) To set order of save callbacks in ActiveRecord, you should use:

```ruby
set_save_order ..., :default, ...
```

Or in common form:

```ruby
set_callbacks_order :save, [..., :default, ...]
```

The latter can be used outside of ActiveRecord, in ActionController or ActiveModel, where ActiveSupport::Callbacks
are included.

To append the order in any inherited class:

```ruby
append_save_order :my_order, before: :default
```

You can specify `:before` or `:after` to specify a place where new order item should be inserted.

2) To set priority for specific callback, you should add `:priority` option to `before_save` or `after_save`.
