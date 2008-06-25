module Crufty
  
  def find_methods(dir, sensitivity = 1)
    Dir[dir.sub(/\/\Z/, '') + '/**/*.rb'].each do |file|
      methods = []
      File.open(file, 'r') do |f|
        f.each_line do |l|
          methods.push l[/def ([a-z_\?!]+)/, 1]
        end
      end
      methods.compact.each do |m|
        grep_results = `grep -r #{m} app lib`
        if(grep_results.split("\n").length <= sensitivity.to_i)
          puts "\n===> #{m} in #{file}"
          puts grep_results
        end
      end
    end  
  end
  
end