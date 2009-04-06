# A System Within a Site will have:
#
# A. Categories
# B. A ClientID
# C. A unique system name provided by the client (default from IP + Time Stamp?)
# D. A CURRENT LIST OF ITEMS

require 'thread'
require 'model/item'

module Shop
  class System
    FINISHED = Queue.new
    PENDING = Queue.new

    @@on_every_update = nil

    attr_accessor :client_id, :name

    def initialize(client_id, name)
      @client_id, @name = client_id, name
      @categories_items = {}
    end

    # keep only the latest item per category
    def add(item)
      return unless item.respond_to?(:category)
      @categories_items[item.category] = item
    ensure
      updated
    end
    alias << add

    # we can get away by deleting by item category, as there may be only one
    # item per category
    def delete(item)
      return unless item.respond_to?(:category)
      @categories_items.delete(item.category)
    ensure
      updated
    end

    # yield every item in this system
    def each_item(&block)
      @categories_items.values.each(&block)
    end

    def items
      @categories_items.values
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

    on_every_update do |system|
      # show the system that has been updated
      pp system
    end
  end
end
