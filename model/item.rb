module Shop
  class Item
    attr_accessor :id, :name, :description

    def initialize(id, name, description)
      @id, @name, @description = id, name, description
    end
  end
end
