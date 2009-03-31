module Shop
  class Main < Controller
    map '/'

    def dropped_in
      return  if ! request.post?
      component_id = request[ 'component_id' ]
      Ramaze::Log.info "Dropped in: #{component_id}."
      { 'result' => "Accepted component #{component_id}." }
    end

    def dropped_out
      return  if ! request.post?
      component_id = request[ 'component_id' ]
      Ramaze::Log.debug "Dropped out: #{component_id}"
      { 'result' => "Extracted component #{component_id}." }
    end
  end
end
