require "mongoid/publishing_logic/version"
require "active_support/concern"
require "mongoid"

module Mongoid
  module PublishingLogic
    extend ::ActiveSupport::Concern

    mattr_writer :active
    self.active = true

    def self.active?
      @@active
    end

    included do
      unless self.include? Mongoid::Document
        raise RuntimeError.new('must be included in a Mongoid model')
      end

      field :published_flag, type: Boolean, default: false
      field :publishing_date, type: Date, default: lambda { Date.today }
      field :publishing_end_date, type: Date

      scope :published, lambda {
        if PublishingLogic.active?
          where(published_flag: true,
                :publishing_date.lte => Date.today)
            .or(
              {publishing_end_date: nil},
              {:publishing_end_date.gt => Date.today}
            )
        else
          all
        end
      }

      scope :unpublished, lambda {
        if PublishingLogic.active?
          self.or(
            {published_flag: false},
            {:publishing_date.gt => Date.today},
            {:publishing_end_date.lte => Date.today}
          )
        else
          where(:_id.in => [])
        end
      }
    end
  end
end
