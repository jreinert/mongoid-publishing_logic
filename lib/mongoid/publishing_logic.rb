require "mongoid/publishing_logic/version"
require "active_support/concern"
require "mongoid"

module Mongoid
  module PublishingLogic
    extend ::ActiveSupport::Concern

    mattr_accessor :active
    self.active = true

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

    def published?
      if PublishingLogic.active?
        published_flag && (
          (publishing_date.nil? || publishing_date <= Date.today) &&
          (publishing_end_date.nil? || publishing_end_date > Date.today)
        )
      else
        true
      end
    end

    module ModuleMethods
      def active?
        self.active
      end

      def activate
        self.active = true
      end

      def deactivate
        self.active = false
      end

      def deactivated(&block)
        with_status(false, &block)
      end

      def activated(&block)
        with_status(true, &block)
      end

      def with_status(status, &block)
        status_was = active?
        begin
          self.active = status
          yield
        ensure
          self.active = status_was
        end
      end
    end

    extend self::ModuleMethods
  end
end
