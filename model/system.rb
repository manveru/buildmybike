# A System Within a Site will have:
#
# A. Categories
# B. A ClientID
# C. A unique system name provided by the client (default from IP + Time Stamp?)
# D. A CURRENT LIST OF ITEMS
#
# See examples at end of file

require 'thread'
require 'model/item'

module Shop
  class System
    FINISHED = Queue.new
    PENDING = Queue.new

    @@on_every_update = nil

    attr_accessor :client_id, :name, :items

    def initialize(client_id, name)
      @client_id, @name = client_id, name
      @cateogries_items = {}
    end

    # keep only the latest item per category
    def add(item)
      @cateogries_items[item.category] = item
    ensure
      updated
    end
    alias << add

    # we can get away by deleting by item category, as there may be only one
    # item per category
    def delete(item)
      @cateogries_items.delete(item.category)
    ensure
      updated
    end

    # yield every item in this system
    def each_item(&block)
      @cateogries_items.values.each(&block)
    end

    def updated
      if callback = @@on_every_update
        callback.call(self)
      else
        PENDING.enq(self)
      end
    end

    def self.on_every_update(&block)
      @@on_every_update = block
    end

    def self.next_update
      PENDING.deq unless PENDING.empty?
    end
  end
end

__END__

# This example shows how to use a dynamic handler that is called every time the
# system is updated.
# Note that we set the handler before any system is even created.
#
# This example will output twice, once for every item added.

puts "before on_every_update is set"

Shop::System.on_every_update do |system|
  # show the system that has been updated
  puts system.inspect
end

puts "after on_every_update was set"

# first create a system
system = Shop::System.new('manveru', 'my next mountainbike')
# fill it with some items
system << Shop::Item.new('baz id', 'baz category', 'baz name', 'baz description')
system << Shop::Item.new('duh id', 'duh category', 'duh name', 'duh description')



# This example shows how to use the non-blocking query for next updated system
#
# This example will output nothing, all the items are now

# first create a system
system = Shop::System.new('manveru', 'my next citybike')
# fill it with some items
system << Shop::Item.new('foo id', 'foo category', 'foo name', 'foo description')
system << Shop::Item.new('bar id', 'bar category', 'bar name', 'bar description')

puts "before next_update is called"

# See whether there is an updated system (there is)
while updated = Shop::System.next_update
  # show the system that has been updated
  puts updated.inspect
end

puts "after next_update is called"
