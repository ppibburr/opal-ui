use Rack::Static,
  :urls => ["/js", "/demo"],
  :root => "./"

run lambda { |env|
  [
    200,
    {
      'Content-Type'  => 'text/html'
    },
    File.open('./demo/index.html', File::RDONLY)
  ]
}
