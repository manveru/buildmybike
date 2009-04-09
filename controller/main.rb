module Shop
  class Main < Controller
    map '/'

    def index
      @all_items = Item.all_by_category
      @system_types = ['City bike', 'Mountain bike']
      @item_types = @all_items.keys
      @items = @all_items[item_type]
    end

    def dropped_in
      return unless request.post?

      item = Item[request[:item_id]]
      system.add(item)

      Ramaze::Log.info("Accepted item: %p." % h(item.inspect))
      { 'result' => system.quick_report }
    end

    def dropped_out
      return unless request.post?

      item = Item[request[:item_id]]
      system.delete(item)

      Ramaze::Log.debug("Extracted item: %p." % h(item.inspect))
      { 'result' => system.quick_report }
    end

    def add_item(id)
      system.add(Item[id])
      redirect_referrer
    end

    def items_for(category)
      Item.all_by_category[category]
    end

    def items_available
      Item.all_by_category
    end

    def items_in_cart
      system.items
    end

    def clear_cart
      system.items.clear
      redirect_referrer
    end

    private

    def system
      session[:system]
    end

    def system_name
      if system_name = request[:system_name]
        system.name = system_name
      else
        system.name
      end
    end

    def system_type
      if system_type = request[:system_type]
        system.type = system_type
      else
        system.type ||= @system_types.first
      end
    end

    def item_type
      if item_type = request[:item_type]
        session[:item_type] = item_type
      else
        session[:item_type] ||= @item_types.first
      end
    end

    before_all do
      session[:system] ||= System.new(session.sid)
    end
  end
end
