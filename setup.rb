#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

def sh(cmd)
  puts cmd
  fail("Bad exit-status") unless system(cmd)
end

def install_git(name, repo, sha)
  Dir.chdir 'vendor' do
    if File.directory?("#{name}/.git")
      Dir.chdir name do
        # switch to master branch
        sh('git checkout master')
        # get latest commits if we don't have the one required
        sh('git pull') unless `git rev-list` =~ /^#{sha}/
        # checkout the state at the required commit
        sh("git checkout #{sha}")
      end
    else
      sh("git clone git://github.com/#{repo}.git")
      Dir.chdir name do
        sh("git checkout #{sha}")
      end
    end
  end
end

mkdir_p 'vendor'

install_git 'rack',   'rack/rack',      'ae3bd27580727453250feb29a722324e185b3dea'
install_git 'ramaze', 'manveru/ramaze', '0395321e8f6938b394957e1f045b5189056ae860'
install_git 'innate', 'manveru/innate', '0809fb114eda6b558bbca4e7c12713e40ab33ad9'

Dir.chdir '../' do
  sh('tar -cvzf buildmybike.tar.gz buildmybike')
  puts "All done, sandbox ready"
end
