require 'mongoid/publishing_logic'

module Mongoid
  describe PublishingLogic do

    before :each do
      PublishingLogic.active = true
    end

    it 'has a writer for the attribute active' do
      expect(PublishingLogic).to respond_to(:active=)
    end


    it 'has an active? method which returns the current state of the active attribute' do
      expect(PublishingLogic).to respond_to(:active?)
      PublishingLogic.active = false
      expect(PublishingLogic.class_variable_get(:@@active)).to be false
      expect(PublishingLogic.active?).to be false
      PublishingLogic.active = true
      expect(PublishingLogic.class_variable_get(:@@active)).to be true
      expect(PublishingLogic.active?).to be true
    end

    it 'has activate and deactivate methods to set active attribute' do
      expect(PublishingLogic).to respond_to(:activate)
      expect(PublishingLogic).to respond_to(:deactivate)

      expect(PublishingLogic.class_variable_get(:@@active)).to eq true
      PublishingLogic.deactivate
      expect(PublishingLogic.class_variable_get(:@@active)).to eq false
      PublishingLogic.activate
      expect(PublishingLogic.class_variable_get(:@@active)).to eq true
    end

    describe '.with_status' do
      it 'expects a value to set the active attribute to' do
        expect { PublishingLogic.with_status }.to raise_error(ArgumentError)
      end

      it 'expects a block' do
        expect { PublishingLogic.with_status(true) }.to raise_error(LocalJumpError)
      end

      it 'sets the publishing logic active attribute to whatever value is passed to it in the codeblock' do
        [true, false].each do |initial_status|
          PublishingLogic.active = initial_status

          [true, false].each do |status|
            PublishingLogic.with_status(status) do
              expect(PublishingLogic.class_variable_get(:@@active)).to be status
            end
          end
        end
      end

      it 'sets the publishing logic active attribute to its previous value outside the codeblock' do
        [true, false].each do |initial_status|
          PublishingLogic.active = initial_status

          [true, false].each do |status|
            PublishingLogic.with_status(status) {}
          end
          expect(PublishingLogic.class_variable_get(:@@active)).to be initial_status

          begin
            PublishingLogic.with_status(status) { raise Class.new(StandardError).new }
          rescue
            expect(PublishingLogic.class_variable_get(:@@active)).to eq initial_status
          end
        end
      end
    end

    {deactivated: false, activated: true}.each do |method, expected_value|
      describe ".#{method}" do
        it 'expects a block' do
          expect { PublishingLogic.send(method) }.to raise_error(LocalJumpError)
        end

        it "turns #{expected_value ? 'on' : 'off'} publishing logic for the codeblock" do
          [true, false].each do |initial_status|
            PublishingLogic.active = initial_status

            PublishingLogic.send(method) do
              expect(PublishingLogic.class_variable_get(:@@active)).to eq expected_value
            end
          end
        end

        it 'sets the active attribute to what it was before the codeblock' do
          [true, false].each do |initial_status|
            PublishingLogic.active = initial_status

            PublishingLogic.send(method) {}

            expect(PublishingLogic.class_variable_get(:@@active)).to eq initial_status

            begin
              PublishingLogic.deactivated { raise Class.new(StandardError).new }
            rescue
              expect(PublishingLogic.class_variable_get(:@@active)).to eq initial_status
            end
          end
        end
      end
    end


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

    def generate_records
      records = []

      [true, false].each do |published_flag|
        Array.new(3) {|index| Date.today + (index - 1) }.each do |publishing_date|
          [nil, *Array.new(3) {|index| Date.today + (index - 1)}].each do |publishing_end_date|
            model = model_class.create!(
              published_flag: published_flag,
              publishing_date: publishing_date,
              publishing_end_date: publishing_end_date
            )
            records << model
          end
        end
      end

      records
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

        records = generate_records
        expected_records = records.select {|record|
          record.published_flag &&
            record.publishing_date <= Date.today &&
            (record.publishing_end_date.nil? || record.publishing_end_date > Date.today)
        }

        expect(model_class.published).to match_array expected_records
      end

      it "returns all records if the global active flag is set to false" do
        PublishingLogic::active = false
        records = generate_records

        expect(model_class.published).to match_array records
      end
    end

    it 'has an unpublished scope' do
      expect(model_class).to respond_to(:unpublished)
    end

    describe 'unpublished scope' do
      it "returns all records, with published_flag set to false\n\t" +
         "or publishing_date in the future\n\t" +
         "or publishing_end_date today or in the past" do

        records = generate_records
        expected_records = records.select {|record|
          !record.published_flag ||
            record.publishing_date > Date.today ||
            (!record.publishing_end_date.nil? && record.publishing_end_date <= Date.today)
        }

        expect(model_class.unpublished).to match_array expected_records
      end

      it "returns an empty query object if the global active flag is set to false" do
        PublishingLogic::active = false
        generate_records

        expect(model_class.unpublished).to match_array []
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

      describe 'published?' do
        it "returns true if the published_flag is set to true,\n\t" +
           "publishing_date is today or in the past and\n\t" +
           "publishing_end_date is in the future" do
          records = generate_records
          expected_records = records.select {|record|
            record.published_flag &&
            record.publishing_date <= Date.today &&
            (record.publishing_end_date.nil? || record.publishing_end_date > Date.today)
          }
          expect(records.select(&:published?)).to match_array expected_records
        end
      end
    end
  end
end
