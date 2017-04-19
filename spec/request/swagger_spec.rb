# frozen_string_literal: true
require 'rails_helper'

require 'saml/settings_service'

RSpec.describe 'API doc validations', type: :request do
  context 'json validation' do
    it 'has valid json' do
      get '/v0/apidocs.json'
      json = response.body
      JSON.parse(json).to_yaml
    end
  end
end

RSpec.describe 'the API documentation', type: :apivore, order: :defined do
  subject { Apivore::SwaggerChecker.instance_for('/v0/apidocs.json') }

  let(:rubysaml_settings) { build(:rubysaml_settings) }
  let(:token) { 'lemmein' }
  let(:mhv_user) { build :mhv_user }

  before do
    Session.create(uuid: mhv_user.uuid, token: token)
    User.create(mhv_user)

    allow(SAML::SettingsService).to receive(:saml_settings).and_return(rubysaml_settings)
  end

  context 'has valid paths' do
    let(:auth_options) { { '_headers' => { 'Authorization' => "Token token=#{token}" } } }

    it 'supports new sessions' do
      expect(subject).to validate(:get, '/v0/sessions/new', 200, level: 1)
    end

    it 'supports session deletion' do
      expect(subject).to validate(:delete, '/v0/sessions', 202, auth_options)
      expect(subject).to validate(:delete, '/v0/sessions', 401)
    end

    it 'supports getting an in-progress form' do
      expect(subject).to validate(
        :get,
        '/v0/in_progress_forms/{id}',
        200,
        auth_options.merge('id' => 'healthcare_application')
      )
      expect(subject).to validate(:get, '/v0/in_progress_forms/{id}', 401, 'id' => 'healthcare_application')
    end

    it 'supports updating an in-progress form' do
      expect(subject).to validate(
        :put,
        '/v0/in_progress_forms/{id}',
        200,
        auth_options.merge(
          'id' => 'healthcare_application',
          '_data' => { 'form_data' => { wat: 'foo' } }
        )
      )
      expect(subject).to validate(
        :put,
        '/v0/in_progress_forms/{id}',
        500,
        auth_options.merge('id' => 'healthcare_application')
      )
      expect(subject).to validate(:put, '/v0/in_progress_forms/{id}', 401, 'id' => 'healthcare_application')
    end

    it 'supports getting the user data' do
      expect(subject).to validate(:get, '/v0/user', 200, auth_options)
      expect(subject).to validate(:get, '/v0/user', 401)
    end
  end

  context 'and' do
    it 'tests all documented routes' do
      expect(subject).to validate_all_paths
    end
  end
end