%w(version coverage railtie).each { |f| require "api_bluerails/#{f}" }

module ApiBluerails
  def self.coverage
    app_urls_hash, covered_urls_hash, uncovered_urls_hash = ApiBluerails::Coverage.coverage
    {'verfügbare Routes' => app_urls_hash, 'dokumentierte Routes' => covered_urls_hash, 'nicht dokumentierte Routes' => uncovered_urls_hash}.each do |title, hash|
      puts "\n\n>>>"
      puts title
      puts "-"*113
      hash.each { |url, verbs| puts sprintf("%80s | %30s", url, verbs.join(', ')) }
      puts sprintf("=%79s | =%29s", hash.keys.count, hash.values.sum { |v| v.count })
      puts "\n<<<"
    end
    exit [uncovered_urls_hash.size, 255].min
  end
end