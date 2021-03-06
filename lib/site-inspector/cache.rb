class SiteInspectorCache
  def initialize
    @memory = {}
  end

  def get(request)
    @memory[request]
  end

  def set(request, response)
    @memory[request] = response
  end
end

class SiteInspectorDiskCache
  def initialize(dir = nil, replace = false)
    @dir = dir
    @memory = {}
    @replace = replace
  end

  def path(request)
    File.join(@dir, request.cache_key)
  end

  def fetch(request)
    if File.exist?(path(request))

      if @replace
        FileUtils.rm(path(request))
        nil
      else
        contents = File.read(path(request))
        begin
          Marshal.load(contents)
        rescue ArgumentError
          FileUtils.rm(path(request))
          nil
        end
      end
    end
  end

  def store(request, response)
    File.open(File.join(@dir, request.cache_key), "w") do |f|
      f.write Marshal.dump(response)
    end
  end

  def get(request)
    @memory[request] || fetch(request)
  end

  def set(request, response)
    store(request, response)
    @memory[request] = response
  end
end
