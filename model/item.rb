module Shop
  class Item
    attr_accessor :id, :category, :name, :description

    def initialize(id, category, name, description)
      @id, @category, @name, @description = id, category, name, description
    end
  end
end
