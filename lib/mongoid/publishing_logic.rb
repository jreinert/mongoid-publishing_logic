require "mongoid/publishing_logic/version"
require "active_support/concern"
require "mongoid"

module Mongoid
  module PublishingLogic
    extend ::ActiveSupport::Concern

    included do
      unless self.include? Mongoid::Document
        raise RuntimeError.new('must be included in a Mongoid model')
      end
    end
  end
end
