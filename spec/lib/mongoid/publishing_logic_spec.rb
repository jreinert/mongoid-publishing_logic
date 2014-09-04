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

    it 'has a published scope' do
      expect(model_class).to respond_to(:published)
    end

    describe 'published scope' do
      it 'only returns records, which have published_flag set to true' do
        [true, false].each do |published_flag|
          model_class.create!(published_flag: published_flag)
        end

        model_class.published.each do |model|
          expect(model.published_flag).to eq true
        end
      end

      it 'only returns records, with publishing_date in the past or today' do
        Array.new(3) {|index| Date.today + (index - 1)}.each do |publishing_date|
          model_class.create!(published_flag: true, publishing_date: publishing_date)
        end

        model_class.published.each do |model|
          expect(model.publishing_date).to be <= Date.today
        end
      end

      it 'only returns records, with publishing_end_date nil or greater than today' do
        [nil, *Array.new(3) {|index| Date.today + (index - 1)}].each do |publishing_end_date|
          model_class.create!(published_flag: true, publishing_end_date: publishing_end_date)
        end

        model_class.published.each do |model|
          unless model.publishing_end_date.nil?
            expect(model.publishing_end_date).to be > Date.today
          end
        end
      end

      it "returns all records, with published_flag set to true,\n\t" +
         "publishing_date in the past or today and\n\t" +
         "publishing_end_date nil or greater than today" do

        expected_records = []
        [true, false].each do |published_flag|
          Array.new(3) {|index| Date.today + (index - 1) }.each do |publishing_date|
            [nil, *Array.new(3) {|index| Date.today + (index - 1)}].each do |publishing_end_date|
              model = model_class.create!(
                published_flag: published_flag,
                publishing_date: publishing_date,
                publishing_end_date: publishing_end_date
              )
              if published_flag &&
                publishing_date <= Date.today &&
                (publishing_end_date.nil? || publishing_end_date > Date.today)

                expected_records << model
              end
            end
          end
        end

        expect(model_class.published).to match_array expected_records
      end
    end

    it 'has an unpublished scope' do
      expect(model_class).to respond_to(:unpublished)
    end

    describe 'unpublished scope' do
      it "returns all records, with published_flag set to false\n\t" +
         "or publishing_date in the future\n\t" +
         "or publishing_end_date today or in the past" do

        expected_records = []
        [true, false].each do |published_flag|
          Array.new(3) {|index| Date.today + (index - 1) }.each do |publishing_date|
            [nil, *Array.new(3) {|index| Date.today + (index - 1)}].each do |publishing_end_date|
              model = model_class.create!(
                published_flag: published_flag,
                publishing_date: publishing_date,
                publishing_end_date: publishing_end_date
              )
              if !published_flag ||
                publishing_date > Date.today ||
                (!publishing_end_date.nil? && publishing_end_date <= Date.today)

                expected_records << model
              end
            end
          end
        end

        expect(model_class.unpublished).to match_array expected_records
      end
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
