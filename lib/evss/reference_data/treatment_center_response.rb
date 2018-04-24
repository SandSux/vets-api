# frozen_string_literal: true

require 'evss/response'

module EVSS
  module ReferenceData
    class TreatmentCenterResponse < EVSS::Response
      attribute :facilities, Array[EVSS::ReferenceData::TreatmentCenter]

      def initialize(status, response = nil)
        super(status, response&.body)
      end
    end
  end
end
