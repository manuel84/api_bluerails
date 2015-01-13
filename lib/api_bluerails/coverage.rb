# encoding: UTF-8
module ApiBluerails
  # main class for covering the rails api doc
  class Coverage
    DEFAULT_HTTP_VERBS = %w(GET POST PUT DELETE)
    EXCEPTIONS = {
        # Rails routes
        '/assets' => DEFAULT_HTTP_VERBS,
        '/rails/info/properties.json' => DEFAULT_HTTP_VERBS
    }
    # main coverage method
    class << self
      def coverage
        load_config
        app_urls = init_app_urls
        covered_urls = init_covered_urls
        uncovered_urls = init_uncovered_urls(app_urls, covered_urls)
        [app_urls, covered_urls, uncovered_urls]
      end

      def load_config
        config_file = Rails.root.join('config', 'api_bluerails.yml')
        return unless File.exist?(config_file)
        config = YAML.load(File.open(config_file)).freeze
        # ignore the following routes
        EXCEPTIONS.merge! config['exceptions'] if config['exceptions']
        true
      end

      def init_app_urls
        routes = Rails.application.routes.routes
        urls = routes.collect { |r| [r.path.spec.to_s, r.constraints] }
        routes_hash(urls)
      end

      def init_covered_urls
        result = {}
        apib_file = File.read api_doc_location(determine_latest_api_version)
        url_holder_pattern = /^##\s.+\[(\/.+)(json|{format})(\{\?.+\})?\]$/
        # Regex for:
        ## User Transaction [/api/users{user_id}.{format}{?user_key,device_id}]
        # =>
        # 1.	/api/users{user_id}.
        # 2.	{format}
        # 3.	{?user_key,device_id}
        http_verb_pattern = /^###\s.+\[(GET|POST|PUT|DELETE)\]$/
        current_url = ''
        apib_file.each_line do |line|
          matchdata = line.match(url_holder_pattern)
          matchdata2 = line.match(http_verb_pattern)
          if matchdata
            current_url = matchdata[1] + matchdata[2]
            current_url.gsub!('{format}', 'json')
            result[current_url] = []
          end
          result[current_url] << matchdata2[1] if matchdata2
        end
        result
      end

      def init_uncovered_urls(app_urls_hash, covered_urls_hash)
        result = {}
        app_urls_hash.each do |url, verbs|
          result[url] = verbs
          result[url] = verbs - covered_urls_hash[url] if covered_urls_hash.key?(url)
          result[url] -= EXCEPTIONS[url] if EXCEPTIONS.key?(url)
        end

        result.delete_if { |_k, v| v.empty? }
      end

      # (/:locale)/sign_in(.:format) => /locale/sign_in(.:format)
      # /devices/:id/assume(.:format) => /devices/:id/assume.json
      # /devices/:device_id/transactions/:id/assume.json
      # => /devices/{device_id}/transactions/:id/assume.json
      # /users/:id.json => /users/{user_id}.json
      # /user/transactions/{id}/receipt.json
      # => /user/transactions/{transaction_id}/receipt.json
      def routes_hash(urls)
        result = Hash.new([])
        urls.each do |app_url, constraint|
          app_url.gsub!('(/:locale)', '/locale')
          app_url.gsub!('(.:format)', '.json')
          app_url.gsub!(/\:([a-zA-Z_]+)\//, '{\1}/')

          if app_url.ends_with?(':id.json')
            crop_index = app_url.split('/')[-2].ends_with?('}') ? -3 : -2
            resource = app_url.split('/')[crop_index]
            app_url.gsub!(':id.json', "{#{resource.singularize}_id}.json")
          end

          if app_url.include?('{id}')
            namespaces = app_url.split('/')
            app_url.gsub!('{id}', "{#{namespaces[namespaces.index('{id}') - 1].singularize}_id}")
          end
          http_methods = if constraint.key?(:request_method)
                           methods = constraint[:request_method].source
                           methods.gsub('^', '').gsub('$', '').split('|')
                         else
                           DEFAULT_HTTP_VERBS
                         end
          result[app_url] += http_methods
        end
        result
      end

      def determine_latest_api_version
        Dir.glob('./app/controllers/api/*').
            map { |p| Pathname.new(p).basename.to_s }.
            select { |s| s.start_with? 'v' }.
            map { |s| s.sub('v', '').to_i }.
            sort.last
      end

      def doc_location(version = nil, sub_dir = 'api', file_extension = 'apib')
        # if version not set => merge them all!
        basename = 'paij_backend'
        basename << "_v#{version}" if version.to_i > 0
        path = Rails.root.join ''
        ['doc', 'gen', sub_dir, "#{basename}.#{file_extension}"].each do |subdir|
          path = path.join subdir
          Dir.mkdir(path.dirname) unless Dir.exist?(path.dirname)
        end
        path
      end

      # version [int] or "all" as special-case
      def api_doc_location(version = nil)
        doc_location version, 'api', 'apib'
      end
    end
  end
end
