require 'mongoid/publishing_logic'

module Mongoid
  describe PublishingLogic do

    it 'raises if included in a non-mongoid model/class' do
      expect {Class.new { include Mongoid::PublishingLogic }}.to raise_error(RuntimeError)
    end

    let :model_class do
      Class.new {
        include Mongoid::Document
        include Mongoid::PublishingLogic
        store_in collection: 'test_models'
      }
    end

    describe 'instance' do
      let :model do
        model_class.new
      end

      it 'has a published flag' do
        expect(model).to respond_to(:published_flag)
      end

      describe 'published_flag' do
        it 'is false by default' do
          expect(model.published_flag).to eq false
        end
      end

      it 'has a publishing date' do
        expect(model).to respond_to(:publishing_date)
      end

      describe 'publishing_date' do
        it "is today's date by default" do
          expect(model.publishing_date).to eq Date.today
        end
      end

      it 'has a publishing end date' do
        expect(model).to respond_to(:publishing_end_date)
      end

      describe 'publishing_end_date' do
        it 'is nil by default' do
          expect(model.publishing_end_date).to be nil
        end
      end
    end
  end
end
