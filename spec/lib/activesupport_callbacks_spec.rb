require 'spec_helper'

RSpec.describe ActiveSupport::Callbacks do
  class Example
    include ActiveSupport::Callbacks

    def self.callbacks
      get_callbacks(:save).entries
    end

    def callbacks
      self.class.callbacks
    end

    def test_method
      run_callbacks :save do
        puts "test method"
      end
    end
  end

  class Example1 < Example
    define_callbacks :save, order: [:first, :default, :last]

    set_callback :save, :before do
      puts "before default"
    end

    set_callback :save, :after do
      puts "after default"
    end

    set_callback :save, :before, priority: :first do
      puts "before first"
    end

    set_callback :save, :after, priority: :last do
      puts "after last"
    end

    set_callback :save, :before, priority: :last do
      puts "before last"
    end

    set_callback :save, :after, priority: :first do
      puts "after first"
    end
  end

  class Example2 < Example
    define_callbacks :save, order: [:default, :another]

    set_callback :save, :before, priority: :another do
      puts "before another"
    end

    set_callback :save, :before do
      puts "before default"
    end
  end

  class Example3 < Example
    define_callbacks :save, order: [:default, :another]

    set_callback :save, :after, priority: :another do
      puts "after another"
    end

    set_callback :save, :after do
      puts "after default"
    end
  end

  class Example4 < Example1
    set_callback :save, :before do
      puts "before example4"
    end
    set_callback :save, :after do
      puts "after example4"
    end
  end

  class Example5 < Example
    define_callbacks :save, order: [:another, :default]

    set_callback :save, :around do |_, block|
      puts "around 1"
      block.call
      puts "around 2"
    end

    set_callback :save, :around, priority: :another do |_, block|
      puts "around 3"
      block.call
      puts "around 4"
    end
  end

  let(:example1) { Example1.new }
  let(:example2) { Example2.new }
  let(:example3) { Example3.new }
  let(:example4) { Example4.new }
  let(:example5) { Example5.new }

  it 'accepts priority in callback options' do
    expect(example2.callbacks[1].priority).to eq(:another)
  end

  it "has default priority if :priority is not specified" do
    expect(example2.callbacks[1].priority).to eq(:another)
  end

  it "has proper order when called" do
    expect { example2.test_method }.to output("before default\nbefore another\ntest method\n").to_stdout
    expect { example3.test_method }.to output("test method\nafter another\nafter default\n").to_stdout
    expect { example1.test_method }.to output("before first\nbefore default\nbefore last\ntest method\nafter last\nafter default\nafter first\n").to_stdout
  end

  it "should fail if unknown priority is specified" do
    expect do
      class ExampleWithException < Example
        define_callbacks :save
        set_callback :save, :after, priority: :another do
          puts "after another"
        end
      end
    end.to raise_error(ArgumentError)
  end

  it "has proper order in derived class" do
    expect { example4.test_method }.to output("before first\nbefore default\nbefore example4\nbefore last\ntest method\nafter last\nafter example4\nafter default\nafter first\n").to_stdout
  end

  it "has proper order when around callbacks are used" do
    expect { example5.test_method }.to output("around 3\naround 1\ntest method\naround 2\naround 4\n").to_stdout
  end
end