require 'mongoid/publishing_logic'

module Mongoid
  describe PublishingLogic do

    it 'raises if included in a non-mongoid model/class' do
      expect {Class.new { include Mongoid::PublishingLogic }}.to raise_error(RuntimeError)
    end
  end
end
