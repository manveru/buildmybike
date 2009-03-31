module Shop
  class Controller < Ramaze::Controller
    layout :default
    trait :app => :shop
    helper :form, :xhtml, :formatting
    provide(:json, :type => 'application/json'){ |action, value| value.to_json }
  end
end

require 'controller/main'
