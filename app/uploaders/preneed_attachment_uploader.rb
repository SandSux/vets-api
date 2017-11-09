# frozen_string_literal: true

class PreneedAttachmentUploader < CarrierWave::Uploader::Base
  include ValidateFileSize

  MAX_FILE_SIZE = 25.megabytes

  def initialize(guid)
    super
    @guid = guid
  end

  def store_dir
    raise 'missing guid' if @guid.blank?
    "preneed_attachments/#{@guid}"
  end
end