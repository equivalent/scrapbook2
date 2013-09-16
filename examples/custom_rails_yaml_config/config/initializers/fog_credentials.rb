CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => LOCAL_APP_CONFIG.send(:[], 'private_key'),
    :aws_secret_access_key  => LOCAL_APP_CONFIG.send(:[], 'secret'),
    :region                 => 'eu-west-1'
  }
  config.fog_directory  = "my-application-bucket-#{Rails.env}"
  config.fog_public     = false
  config.fog_attributes = {'Cache-Control'=>'max-age=3600'}
end

