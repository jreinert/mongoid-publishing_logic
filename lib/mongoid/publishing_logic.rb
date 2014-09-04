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

      field :published_flag, type: Boolean, default: false
      field :publishing_date, type: Date, default: lambda { Date.today }
      field :publishing_end_date, type: Date
    end
  end
end
