# encoding: UTF-8
%w(version coverage railtie).each { |f| require "api_bluerails/#{f}" }

# Api Bluerails module
module ApiBluerails
  def self.coverage
    app_urls_hash, covered_urls_hash, uncovered_urls_hash =
        ApiBluerails::Coverage.coverage
    { 'verfügbare Routes' => app_urls_hash,
      'dokumentierte Routes' => covered_urls_hash,
      'nicht dokumentierte Routes' => uncovered_urls_hash
    }.each do |title, hash|
      puts "\n\n>>>\n#{title}\n#{'-' * 113}"
      hash.each do |url, verbs|
        puts sprintf('%80s | %30s', url, verbs.join(', '))
      end
      puts sprintf('=%79s | =%29s', hash.keys.count, hash.values.sum(&:count))
      puts "\n<<<"
    end
    exit [uncovered_urls_hash.size, 255].min
  end
end
