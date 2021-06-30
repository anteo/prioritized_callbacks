require 'spec_helper'

RSpec.describe ActiveRecord::Callbacks do
  before(:all) do
    ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

    ActiveRecord::Schema.define version: 0 do
      create_table :records do |t|
        t.text :text, null: false, default: ''
      end
    end
  end

  class Record < ActiveRecord::Base
    self.table_name = 'records'
  end

  class Record0 < Record
    before_save do
      self.text += "0"
    end

    after_save do
      self.text += "9"
    end
  end

  class Record1 < Record0
    before_save do
      self.text += '1'
    end
    before_save do
      self.text += '2'
    end
    after_save do
      self.text += '3'
    end
    after_save do
      self.text += '4'
    end
  end

  class Record2 < Record0
    set_save_order :first, :default, :last

    after_save do
      self.text += '5'
    end
    before_save priority: :last do
      self.text += '3'
    end
    after_save priority: :last do
      self.text += '6'
    end
    before_save priority: :first do
      self.text += '1'
    end
    after_save priority: :first do
      self.text += '4'
    end
    before_save do
      self.text += '2'
    end
  end

  class Record3 < Record2
    set_save_order :last, :default, :first

    after_save priority: :first do
      self.text += '8'
    end
  end

  class Record4 < Record
    set_save_order :another, :default

    around_save  do |_, block|
      self.text += "3"
      block.call
      self.text += "4"
    end

    around_save priority: :another do |_, block|
      self.text += "1"
      block.call
      self.text += "2"
    end
  end

  class Record5 < Record2
    append_save_order :final

    before_save priority: :final do
      self.text += 'X'
    end
  end

  class Record6 < Record5
    append_save_order :initial, before: :first

    before_save priority: :initial do
      self.text += 'Y'
    end
  end

  let(:record1) { Record1.new.tap(&:save) }
  let(:record2) { Record2.new.tap(&:save) }
  let(:record3) { Record3.new.tap(&:save) }
  let(:record4) { Record4.new.tap(&:save) }
  let(:record5) { Record5.new.tap(&:save) }
  let(:record6) { Record6.new.tap(&:save) }

  it 'has default order if order is not specified' do
    expect(record1.text).to eq('012934')
  end

  it 'has proper order when order is specified' do
    expect(record2.text).to eq('10234956')
  end

  it "base class doesn't have order defined" do
    expect(Record.send(:get_callbacks, :save).config[:order]).to eq([:default])
  end

  it "allows to change the order in derived class" do
    expect(record3.text).to eq('302169548')
  end

  it "has proper order when around is used" do
    expect(record4.text).to eq('1342')
  end

  it "has proper order when new order item is appended" do
    expect(record5.text).to eq('1023X4956')
  end

  it "has proper order when new order item is appended to the beginning" do
    expect(record6.text).to eq('Y1023X4956')
  end
end
