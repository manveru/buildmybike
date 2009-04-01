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

install_git 'rack',   'rack/rack',      '4cc1d6e773f64c20849b1d8088717a084b06830a'
install_git 'ramaze', 'manveru/ramaze', '0395321e8f6938b394957e1f045b5189056ae860'
install_git 'innate', 'manveru/innate', '8e93e8793978d0eabe3a8734455c6611e1ce17b2'

Dir.chdir '../' do
  sh('tar -cvzf buildmybike.tar.gz buildmybike')
  puts "All done, sandbox ready"
end
