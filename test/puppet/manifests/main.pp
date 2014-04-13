class { 'mongodbmms':
  api_key => Env['MMS_API_KEY']
}

include mongodbmms


