module AppConstants
  APP_URL        = String(ENV.fetch("APP_URL")).freeze
  FRONT_BASE_URL = String(ENV.fetch("FRONT_BASE_URL")).freeze
  AI_BASE_URL    = String(ENV.fetch("AI_BASE_URL")).freeze
end
