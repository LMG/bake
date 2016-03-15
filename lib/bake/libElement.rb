module Bake
  
  class LibElement
    
    LIB = 1
    USERLIB = 2
    LIB_WITH_PATH = 3
    SEARCH_PATH = 4
    DEPENDENCY = 5

    attr_reader :type, :value
    
    def initialize(type, value)
      @type = type
      @value = value
    end
  end
  
  class LibElements  
      
    def self.calc_linker_lib_string(block, tcs)
      @@lib_path_set = []
      @@dep_set = Set.new
      @@linker = tcs[:LINKER]
      @@projectDir = block.projectDir
      @@source_libraries = []
      @@linker_libs_array = []
      
      collect_recursive(block)
      
      if @@linker[:LIST_MODE] and not @@lib_path_set.empty?
        @@linker_libs_array << (@@linker[:LIB_PATH_FLAG] + @@lib_path_set.join(","));
      end
      
      return [@@source_libraries, @@linker_libs_array] 
    end
    
    def self.adaptPath(path, block, prefix)
      adaptedPath = path
      if not File.is_absolute?(path)
        prefix ||= File.rel_from_to_project(@@projectDir,block.projectDir)
        adaptedPath = prefix + path if prefix
      end
      #adaptedPath = "\"" + adaptedPath + "\"" if adaptedPath.include?(" ")
      [adaptedPath, prefix]
    end
    
    def self.collect_recursive(block)
      return if @@dep_set.include?block
      @@dep_set << block
        
      prefix = nil

      if block.library 
        if (not block.library.compileBlock.objects.empty?) or not block.library.compileBlock.calcSources(true, true).empty?
          adaptedPath, prefix = adaptPath(block.library.archive_name, block, prefix)
          @@linker_libs_array << adaptedPath
          @@source_libraries << adaptedPath
        end
      end
     
      block.lib_elements.each do |elem|
       
        case elem.type
        when LibElement::LIB
          @@linker_libs_array << "#{@@linker[:LIB_FLAG]}#{elem.value}"
        when LibElement::USERLIB
          @@linker_libs_array << "#{@@linker[:USER_LIB_FLAG]}#{elem.value}"
        when LibElement::LIB_WITH_PATH
          adaptedPath, prefix = adaptPath(elem.value, block, prefix)
          @@linker_libs_array <<  adaptedPath
        when LibElement::SEARCH_PATH
          adaptedPath, prefix = adaptPath(elem.value, block, prefix)
          if not @@lib_path_set.include?adaptedPath
            @@lib_path_set << adaptedPath
            @@linker_libs_array << "#{@@linker[:LIB_PATH_FLAG]}#{adaptedPath}" if @@linker[:LIST_MODE] == false
          end
        when LibElement::DEPENDENCY
          if Blocks::ALL_BLOCKS.include?elem.value
            bb = Blocks::ALL_BLOCKS[elem.value]
            collect_recursive(bb)
          else
            # TODO: warning or error?
          end
        end
      end
    end      
    
    
    
    
    def self.calcLibElements(block)
      lib_elements = [] # value = array pairs [type, name/path string]
      
      block.config.libStuff.each do |l|
        
        if (Metamodel::UserLibrary === l)
          ln = l.name
          ls = nil
          if l.name.include?("/")
            pos = l.name.rindex("/")
            ls = block.convPath(l.name[0..pos-1], l)
            ln = l.name[pos+1..-1]
          end
          lib_elements << LibElement.new(LibElement::SEARCH_PATH, ls) if !ls.nil?
          lib_elements << LibElement.new(LibElement::USERLIB, ln)
        elsif (Metamodel::ExternalLibrarySearchPath === l)
          lib_elements << LibElement.new(LibElement::SEARCH_PATH, block.convPath(l))
        elsif (Metamodel::ExternalLibrary === l)
          ln = l.name
          ls = nil
          if l.name.include?("/")
            pos = l.name.rindex("/")
            ls = block.convPath(l.name[0..pos-1], l)
            ln = l.name[pos+1..-1]
          end
          if l.search
            lib_elements << LibElement.new(LibElement::SEARCH_PATH, ls) if !ls.nil?
            lib_elements << LibElement.new(LibElement::LIB, ln)
          else
            ln = ls + "/" + ln unless ls.nil?
            lib_elements << LibElement.new(LibElement::LIB_WITH_PATH, ln)
          end        
        elsif (Metamodel::Dependency === l)
          lib_elements << LibElement.new(LibElement::DEPENDENCY, l.name+","+l.config)
        end
        
      end
    
      return lib_elements
    end      
     
  end
  
end
