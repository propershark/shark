SimpleCov.start do
  add_filter 'spec/'

  add_group 'Middleware', 'middlewares/'
  add_group('Core'){ |file| !file.filename.start_with?('middlewares/') }
end
