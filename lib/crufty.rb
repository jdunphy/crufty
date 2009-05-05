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
          puts m.references if sensitivity > 1
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
      @references = `grep -r #{name} app lib#{scm_based_refinement}`.split("\n")
    end
    
    def scm_based_refinement
      if self.class.scm == :svn
        ' | grep -v \\.svn'
      else
        ''
      end
    end
    
    def crufty?(sensitivity)
      cruft_check unless references
      references.length <= sensitivity
    end
    
    def self.scm
      @scm ||= if File.exists?('.svn')
        :svn
      else
        "something we don't need to worry about"
      end
    end
  end
end