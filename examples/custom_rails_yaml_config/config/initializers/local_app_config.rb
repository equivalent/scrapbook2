begin
  LOCAL_CONFIG = YAML.load_file("#{Rails.root}/config/local_config.yml")[Rails.env] || {}
rescue
  Rails.logger.warn "No config/local_config.yml not found"
  LOCAL_CONFIG = {}
end
