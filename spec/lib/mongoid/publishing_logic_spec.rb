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
    end
  end
end
