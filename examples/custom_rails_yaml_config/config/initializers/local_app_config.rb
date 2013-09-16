begin
  LOCAL_APP_CONFIG = YAML.load_file("#{Rails.root}/config/local_app_config.yml")[Rails.env] || {}
rescue
  Rails.logger.warn "No config/local_app_config.yml not found"
  LOCAL_APP_CONFIG = {}
end
