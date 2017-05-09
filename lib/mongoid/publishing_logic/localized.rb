require 'mongoid/publishing_logic'

module Mongoid
  module PublishingLogic::Localized
    extend ::ActiveSupport::Concern
    include PublishingLogic

    included do
      field :published_flag, type: Boolean, default: false, localize: true
      field :publishing_date, type: Date, default: lambda { Date.today }, localize: true
      field :publishing_end_date, type: Date, localize: true

      scope :published, lambda {|locale=I18n.locale|
        if PublishingLogic.active?
          locale_was = I18n.locale
          begin
            I18n.locale = locale
            where(
              published_flag: true,
              :$and => [
                {:$or => [
                  {:publishing_date.exists => false},
                  {:publishing_date => nil},
                  {:publishing_date.lte => Date.today}
                ]},
                {:$or => [
                  {publishing_end_date: nil},
                  {:publishing_end_date.gt => Date.today}
                ]}
              ]
            )
          ensure
            I18n.locale = locale_was
          end
        else
          all
        end
      }

      scope :unpublished, lambda {|locale=I18n.locale|
        if PublishingLogic.active?
          locale_was = I18n.locale
          begin
            I18n.locale = locale
            self.or(
              {published_flag: false},
              {:publishing_date.gt => Date.today},
              {:publishing_end_date.lte => Date.today}
            )
          ensure
            I18n.locale = locale_was
          end
        else
          where(:_id.in => [])
        end
      }
    end

    def published?(locale=I18n.locale)
      locale_was = I18n.locale
      begin
        I18n.locale = locale
        super()
      ensure
        I18n.locale = locale_was
      end
    end

    def published_flag
      super || false
    end

    def publishing_date
      super || publishing_date_translations[I18n.default_locale]
    end

    def publishing_end_date
      super || publishing_end_date_translations[I18n.default_locale]
    end
  end
end
