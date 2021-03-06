=begin
                  Arachni
  Copyright (c) 2010-2012 Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>

  This is free software; you can copy and distribute and modify
  this program under the term of the GPL v2.0 License
  (See LICENSE file for details)

=end

require 'datamapper'

module Arachni
module UI
module Web

#
# A simple logger using DataMapper
#
# @author: Tasos "Zapotek" Laskos
#                                      <tasos.laskos@gmail.com>
#                                      <zapotek@segfault.gr>
# @version: 0.1.1
#
class Log

    class Entry
        include DataMapper::Resource

       def self.default_repository_name
         :log
       end

        property :id,           Serial
        property :action,       String
        property :object,       String
        property :client_addr,  String
        property :client_host,  String
        property :owner,        String
        property :datestamp,     DateTime
    end


    def initialize( opts, settings )

        @opts     = opts
        @settings = settings

        DataMapper::setup( :log, "sqlite3://#{@settings.db}/log.db" )
        DataMapper.repository( :log ) {
            DataMapper.finalize
            Entry.auto_upgrade!
        }
    end

    def entry
        DataMapper.repository( :log ) { Entry }
    end

    def method_missing( sym, *args, &block )

        owner, action = sym.to_s.split( '_', 2 )

        if args && args[1]
            object = args[1]
        end

        if env = args[0]
            addr = env['REMOTE_ADDR']
            host = env['REMOTE_HOST']
        end

        DataMapper.repository( :log ) {
            Entry.create(
                :action => action,
                :owner  => owner,
                :object => object,
                :client_addr => addr,
                :client_host => host,
                :datestamp   => Time.now.asctime
            )
        }
    end

end

end
end
end
