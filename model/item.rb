module Shop
  class Item
    attr_accessor :id, :category, :name, :description

    def initialize(id, category, name, description)
      @id, @category, @name, @description = id, category, name, description
    end

    def to_json
      { :id => id,
        :category => category,
        :name => name,
        :description => description }.to_json
    end

    def self.[](id)
      ITEMS.find{|item| item.id == id }
    end

    def self.all_by_category
      list = Hash.new{|h,k| h[k] = [] }
      ITEMS.each{|item| list[item.category] << item }
      list
    end

    ITEMS = [
      Item.new("n11", 'handle', 'cool handle', 'good quality'),
      Item.new("n12", 'handle', 'good-enough handle', 'medium quality'),
      Item.new("n13", 'handle', 'slippery handle', 'bad quality'),
      Item.new("n21", 'light', 'bright light', 'good quality'),
      Item.new("n22", 'light', 'medium light', 'medium quality'),
      Item.new("n23", 'light', 'dim light', 'bad quality'),
    ]
  end
end
