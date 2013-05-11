begin
  require "digest" 
  Digest::SHA1.hexdigest('test')
rescue LoadError
  $stderr.print "Using native Ruby SHA1 (slow)\n"
  $ruby_sha1 = true
end

module OnceOnly
    
  module Check
    # filter out all arguments that reflect existing files
    def Check::get_file_list list
      list.map { |arg| get_existing_filename(arg) }.compact
    end

    # filter out all names accoding to filters
    def Check::filter_file_list list, regex
      list.map { |name| ( name =~ /#{regex}/ ? nil : name ) }.compact
    end

    # filter out all names accoding to glob (this is not an efficient
    # implementation, as the glob runs for every listed file!)
    def Check::filter_file_list_glob list, glob
      list.map { |name| ( Dir.glob(glob).index(name) ? nil : name ) }.compact
    end

    # Calculate the checksums for each file in the list
    def Check::calc_file_checksums list
      list.map { |fn|
        ['MD5'] + `/usr/bin/md5sum #{fn}`.split
      }
    end

    def Check::calc_hash(buf)
      if $ruby_sha1
        Sha1::sha1(buf)
      else
        Digest::SHA1.hexdigest(buf)
      end
    end

    # Create a file name out of the content of checksums
    def Check::make_once_filename checksums, prefix = 'once-only'
      buf = checksums.map { |entry| entry }.join("\n")
      prefix + '-' + calc_hash(buf) + '.txt'
    end

    def Check::write_file fn, checksums
      File.open(fn,'w') { |f|
        checksums.each { |items| f.print items[0],"\t",items[1],"\t",items[2],"\n" }
      }
    end
   
    # Put quotes around regexs and globs 
    def Check::requote list
      a = [ list[0] ]
      list.each_cons(2) { |pair| a << (['--skip-glob','--skip-regex'].index(pair[0]) ? "'#{pair[1]}'" : pair[1]) }
      a
    end

    def Check::drop_pbs_option(list)
      a = [ list[0] ]
      list.each_cons(2) { |pair| a << pair[1] if pair[0] != '--pbs' and pair[1] != '--pbs'}
      a
    end


protected

    def Check::get_existing_filename arg
      return arg if File.exist?(arg)
      # sometimes arguments are formed as -in=file
      (option,filename) = arg.split(/=/)
      return filename if filename and File.exist?(filename)
      nil
    end
  end

end
