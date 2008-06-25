module Crufty
  
  def self.find_methods(dir, sensitivity)
    Dir.chdir(RAILS_ROOT)
    sensitivity = (sensitivity || 1).to_i
    Dir["#{dir.sub(/\/\Z/, '')}/**/*.rb"].each do |file|
      methods = []
      File.open(file, 'r') do |f|
        f.each_line do |l|
          methods.push l[/def ([a-z_\?\.!]+)/, 1]
        end
      end
      methods.compact.map {|m| CruftyMethod.new(m)}.each do |m|
        if m.crufty?(sensitivity)
          puts "\n===> #{m.to_s} in #{file}"
          puts m.references
        end
      end
    end  
  end
  
  class CruftyMethod
    attr_accessor :name, :references
    def initialize(prefixed_name)
      prefixed_name.sub!(/\A\./, '')
      if prefixed_name.index('.')
        @prefix, @name = prefixed_name.split('.', 2)
      else
        @name = prefixed_name
      end
    end
    
    def to_s
      @prefix ? "#{@prefix}.#{name}" : name
    end
    
    def cruft_check
      self.references = `grep -r #{name} app lib`.split("\n")
    end
    
    def crufty?(sensitivity)
      cruft_check unless references
      references.length <= sensitivity
    end
  end
end