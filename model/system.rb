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

    attr_accessor :type, :client_id, :name, :info
    attr_reader :items

    def initialize(client_id, name = 'unnamed')
      @client_id, @name = client_id, name
      @items = []
    end

    # keep only the latest item per category
    def add(item)
      return unless item.respond_to?(:category)

      @items << item

      updated
    end
    alias << add

    # we can get away by deleting by item category, as there may be only one
    # item per category
    def delete(item)
      return unless item.respond_to?(:category)

      if index = @items.index(item)
        @items.delete_at(index)
        updated
      end
    end

    # yield every item in this system
    def each_item(&block)
      @items.each(&block)
    end

    def updated
      if callback = @@on_every_update
        callback.call(self)
      else
        PENDING.enq(self)
      end
    end

    # Just a placeholder, this is where the final report should be found.
    def final_report
      <<-LOREM.strip.gsub(/^(.*)$/, '<p>\1</p>')
Dolor at nihil et labore et adipisci aut. Laboriosam maiores qui doloremque corrupti voluptatum ut asperiores possimus. Reiciendis dignissimos veniam repellendus.
Ut cum sunt repudiandae libero quasi est eum optio. Quo eum soluta eaque voluptatibus aliquid similique nisi. Nemo itaque quibusdam neque accusantium facere commodi. Et sit a amet et aperiam ut expedita.
Cumque molestias rerum fugiat pariatur facere repellat autem non. Omnis corrupti doloremque laboriosam fugiat tempore magni exercitationem sed. Sed accusamus nihil voluptas aspernatur cum praesentium aliquid. Ipsam alias voluptatem sint.
Eveniet expedita voluptas pariatur quaerat. Aliquam voluptatum ut pariatur animi. In ut laudantium atque temporibus aut qui. Ut tempora vel ut sapiente facere corrupti ratione hic. Accusamus minus corrupti quia itaque ab nesciunt est.
     LOREM
    end

    # This should generate some advice as fast as possible so the UI is smooth.
    #
    # For now we emulate some delay. This will generate advice for the system
    # as it was 5 seconds ago.
    def quick_report
      message = "The system called %p is a %p with %d components"
      info = message % [name, type, items.size]
      sleep 5
      info
    end

    def self.on_every_update(&block)
      @@on_every_update = block
    end

    def self.next_update
      PENDING.deq unless PENDING.empty?
    end

    on_every_update do |system|
    end
  end
end
