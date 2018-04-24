# frozen_string_literal: true

require 'rails_helper'

describe EVSS::ReferenceData::Service do
  let(:user) { build(:user, :loa3) }
  subject { described_class.new(user) }

  describe '#get_treatment_centers' do
    context 'returns a valid response' do
      it 'when retrieving all treatment centers' do
        VCR.use_cassette('evss/reference_data/treatment_centers') do
          response = subject.get_treatment_centers
          expect(response).to be_ok
          expect(response).to be_an EVSS::ReferenceData::TreatmentCenterResponse
          expect(response.facilities.count).to eq 5
        end
      end

      it 'when retrieving state specific treatment centers' do
        VCR.use_cassette('evss/reference_data/treatment_centers_texas') do
          response = subject.get_treatment_centers('TX')
          expect(response).to be_ok
          expect(response).to be_an EVSS::ReferenceData::TreatmentCenterResponse
          expect(response.facilities.count).to eq 1
        end
      end

      it 'when retrieving and invalid state pattern' do
        VCR.use_cassette('evss/reference_data/treatment_centers') do
          response = subject.get_treatment_centers('AAA')
          expect(response).to be_ok
          expect(response).to be_an EVSS::ReferenceData::TreatmentCenterResponse
          expect(response.facilities.count).to eq 5
        end
      end
    end

    context 'with an http timeout' do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::TimeoutError)
      end

      it 'should log an error and raise GatewayTimeout' do
        expect(StatsD).to receive(:increment).once.with(
          'api.evss.get_treatment_centers.fail', tags: ['error:Common::Exceptions::GatewayTimeout']
        )
        expect(StatsD).to receive(:increment).once.with('api.evss.get_treatment_centers.total')
        expect { subject.get_treatment_centers }.to raise_error(Common::Exceptions::GatewayTimeout)
      end
    end

    context 'when service returns a 403' do
      subject { described_class.new(user).get_treatment_centers }
      it 'contains 403 in meta' do
        VCR.use_cassette('evss/reference_data/treatment_centers_403') do
          expect(StatsD).to receive(:increment).once.with(
            'api.evss.get_treatment_centers.fail', tags: ['error:Common::Client::Errors::ClientError', 'status:403']
          )
          expect(StatsD).to receive(:increment).once.with('api.evss.get_treatment_centers.total')
          expect { subject }.to raise_error(Common::Exceptions::Forbidden)
        end
      end
    end
  end
end
