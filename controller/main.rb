module Shop
  class Main < Controller
    map '/'

    def index
      @items = {
        :handles => Array.new(5){|n| Item.new("h#{n}1", 'handle', 'cool handle', 'good quality') },
        :lights => Array.new(5){|n| Item.new("h#{n}2", 'light', 'bright light', 'very good') }
      }
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
