module Shop
  class Main < Controller
    map '/'

    def index
      @items = []
      5.times do |n|
        @items << Item.new("h#{n}1", 'Cool handle', 'Some cool quality handle')
        @items << Item.new("h#{n}2", 'Medium handle', 'Some medium quality handle')
        @items << Item.new("h#{n}3", 'Lame handle', 'Some lame quality handle')
      end
    end

    def dropped_in
      return  if ! request.post?
      item_id = request[ 'item_id' ][/^item-(.*)/, 1]
      Ramaze::Log.info "Dropped in: #{item_id}."
      { 'result' => "Accepted item #{item_id}." }
    end

    def dropped_out
      return  if ! request.post?
      item_id = request[ 'item_id' ][/^item-(.*)/, 1]
      Ramaze::Log.debug "Dropped out: #{item_id}"
      { 'result' => "Extracted item #{item_id}." }
    end
  end
end
