require 'mongoid/publishing_logic/localized'
require_relative '../publishing_logic_spec'

module Mongoid
  describe PublishingLogic::Localized do
    before do
      I18n.available_locales = [:de, :en]
    end

    it_behaves_like('publishing logic')

    let(:publishing_logic) { described_class }

    let :model_class do
      klass = Class.new {
        include Mongoid::Document
        store_in collection: 'test_models'
      }
      klass.send(:include, publishing_logic)
    end

    describe '#publishing_date' do
      let(:publishing_date) { Date.today }

      it 'falls back to the default locale if unset in other locale' do
        I18n.locale = :en

        model = model_class.create!(
          published_flag: true,
          publishing_date: publishing_date
        )

        I18n.locale = :de
        expect(model.publishing_date).to eq(publishing_date)
      end
    end

    describe '#publishing_end_date' do
      let(:publishing_end_date) { Date.today }

      it 'falls back to the default locale if unset in other locale' do
        I18n.locale = :en

        model = model_class.create!(
          published_flag: true,
          publishing_end_date: publishing_end_date
        )

        I18n.locale = :de
        expect(model.publishing_end_date).to eq(publishing_end_date)
      end
    end
  end
end
