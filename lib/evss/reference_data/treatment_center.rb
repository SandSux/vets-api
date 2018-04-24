# frozen_string_literal: true

require 'common/models/base'

module EVSS
  module ReferenceData
    class TreatmentCenter < Common::Base
      attribute :id, Integer
      attribute :name, String
      attribute :city, String
      attribute :state, String
    end
  end
end
