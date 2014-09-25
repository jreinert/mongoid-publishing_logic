require 'mongoid/publishing_logic/localized'
require_relative '../publishing_logic_spec'

module Mongoid
  describe PublishingLogic::Localized do
    it_behaves_like('publishing logic')
  end
end
