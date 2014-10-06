module ApiBluerails
  class Coverage
    def self.coverage
      routes = Rails.application.routes.routes
      app_urls_hash = Hash.new([])
      app_urls = routes.collect { |r| [r.path.spec.to_s, r.constraints] }
      app_urls.each do |app_url, constraint|
        app_url.gsub!('(/:locale)', '/locale') # (/:locale)/users/sign_in(.:format) => /locale/users/sign_in(.:format)
        app_url.gsub!('(.:format)', '.json') # /api/v2/devices/:device_id/transactions/:id/assume(.:format) => /api/v2/devices/:device_id/transactions/:id/assume.json
        app_url.gsub!(/\:([a-zA-Z_]+)\//, '{\1}/') # /api/v2/devices/:device_id/transactions/:id/assume.json => /api/v2/devices/{device_id}/transactions/:id/assume.json

        if app_url.ends_with?(':id.json')
          resource = app_url.split('/')[-2].ends_with?('}') ? app_url.split('/')[-3] : app_url.split('/')[-2]
          app_url.gsub!(':id.json', "{#{resource.singularize}_id}.json") # /api/v2/user/transactions/:id.json => /api/v2/user/transactions/{transaction_id}.json
        end

        if app_url.include?('{id}')
          namespaces = app_url.split('/')
          app_url.gsub!('{id}', "{#{namespaces[namespaces.index('{id}')-1].singularize}_id}") # /api/v2/user/transactions/{id}/receipt.json => /api/v2/user/transactions/{transaction_id}/receipt.json
        end
        app_urls_hash[app_url] += constraint.has_key?(:request_method) ? constraint[:request_method].source.gsub('^', '').gsub('$', '').split('|') : %w(GET POST PUT DELETE)
      end

      #puts app_urls_hash

      apib_file = File.read api_doc_location(determine_latest_api_version)
      url_holder_pattern = /^##\s.+\[(\/.+)(json|{format})(\{\?.+\})?\]$/
      # Regex for:
      ## User Transaction [/api/v2/user/transactions/{transaction_id}.{format}{?user_key,device_id}]
      # =>
      #1.	/api/v2/user/transactions/{transaction_id}.
      #2.	{format}
      #3.	{?user_key,device_id}

      http_verb_pattern = /^###\s.+\[(GET|POST|PUT|DELETE)\]$/
      covered_urls_hash = {}
      current_url = ""
      apib_file.each_line do |line|
        matchdata = line.match(url_holder_pattern)
        matchdata2 = line.match(http_verb_pattern)
        if matchdata
          current_url = matchdata[1] + matchdata[2]
          current_url.gsub!('{format}', 'json')
          covered_urls_hash[current_url] = []
        end
        covered_urls_hash[current_url] << matchdata2[1] if matchdata2
      end


      # ignore the following routes
      exceptions = {
          # Rails routes
          '/assets' => %w(GET POST PUT DELETE),
          '/rails/info/properties.json' => %w(GET POST PUT DELETE)
      }
      config_file = Rails.root.join('config', 'api_bluerails.yml')
      if File.exists?(config_file)
        config = YAML.load(File.open(config_file)).freeze
        exceptions.merge! config['exceptions'] if config['exceptions']
      end

      uncovered_urls_hash = {}
      app_urls_hash.each do |url, verbs|
        uncovered_urls_hash[url] = verbs
        uncovered_urls_hash[url] = verbs - covered_urls_hash[url] if covered_urls_hash.has_key?(url)
        uncovered_urls_hash[url] -= exceptions[url] if exceptions.has_key?(url)
      end


      uncovered_urls_hash.delete_if { |k, v| v.empty? }
      return app_urls_hash, covered_urls_hash, uncovered_urls_hash
    end
  end

end