=begin
                  Arachni
  Copyright (c) 2010-2012 Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>

  This is free software; you can copy and distribute and modify
  this program under the term of the GPL v2.0 License
  (See LICENSE file for details)

=end

module Arachni

module Modules

#
# Looks for common files on the server, based on wordlists generated from open source repositories.
#
# More information about the SVNDigger wordlists:
#   http://www.mavitunasecurity.com/blog/svn-digger-better-lists-for-forced-browsing/
#
# The SVNDigger word lists were released under the GPL v3.0 License.
#
# @author: Herman Stevens
#                                      <herman.stevens@gmail.com>
#                                      http://blog.astyran.sg
#
# @version: 0.1
#
# @see http://cwe.mitre.org/data/definitions/538.html
#
class SvnDiggerFiles < Arachni::Module::Base

    include Arachni::Module::Utilities

    def initialize( page )
        super( page )
    end

	def prepare
        # to keep track of the requests and not repeat them
        @@__audited ||= Set.new

        @@__filenames ||=[]
        return if !@@__filenames.empty?

        read_file( 'all.txt' ) {
            |file|
            @@__filenames << file unless file.include?( '?' )
        }

        read_file( 'all-extensionless.txt' ) {
            |file|
            @@__filenames << file unless file.include?( '?' )
        }

	end

    def run( )
        path = get_path( @page.url )
        return if @@__audited.include?( path )

        print_status( "Scanning SVNDigger Files..." )

        @@__filenames.each {
            |file|

            url  = path + file
            print_status( "Checking for #{url}" )

            log_remote_file_if_exists( url ) {
                |res|
                print_ok( "Found #{file} at " + res.effective_url )
            }
        }

        @@__audited << path
    end


    def self.info
        {
            :name           => 'SVNDigger Files',
            :description    => %q{Finds files, based on wordlists created from open source repositories.

                The wordlist utilized by this module will be vast and will add a considerable
                amount of time to the overall scan time.},
            :elements       => [ ],
            :author         => 'Herman Stevens <herman.stevens@gmail.com> ',
            :version        => '0.1',
            :references     => {
                'Mavituna Security' =>
                    'http://www.mavitunasecurity.com/blog/svn-digger-better-lists-for-forced-browsing/',
                'OWASP Testing Guide' =>
                    'https://www.owasp.org/index.php/Testing_for_Old,_Backup_and_Unreferenced_Files_(OWASP-CM-006)'
        	},
            :targets        => { 'Generic' => 'all' },
            :issue          => {
                :name        => %q{A SVNDigger file was detected.},
                :description => %q{},
                :tags        => [ 'svndigger', 'path', 'file', 'discovery' ],
                :cwe         => '538',
                :severity    => Issue::Severity::INFORMATIONAL,
                :cvssv2      => '',
                :remedy_guidance    => 'Review these resources manually. Check if unauthorized interfaces are exposed,
                    or confidential information.',
                :remedy_code => '',
            }

        }
    end

end
end
end
