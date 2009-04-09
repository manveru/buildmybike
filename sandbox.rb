#!/usr/bin/env ruby

# This little executable creates sandboxes from git repositories using `git archive`.
#
# It creates the sandbox initially in a temporary directory, and a .tar.bz2 is
# made from the result.
#
# Dependencies are put into <name>/vendor/<dependency-basename> directories.
#
# So given an invocation like:
#
#   sandbox -n blog -d ~/repo/innate,~/repo/ramaze,~/repo/rack -s ~/repo/blog
#
# This will create a sandbox that has a rough structure of:
#
#   blog
#   `-- vendor
#       |-- innate
#       |   `-- lib
#       |-- rack
#       |   `-- lib
#       `-- ramaze
#           `-- lib
#
# Since we are using `git archive`, the resulting sandbox will not have any
# `.git` directories and they will not be considered repositories anymore.
#
# Also, we assume that the repository keeps the things we care about in the
# /lib directory, and we don't package anything else.
#
# This way we can get optimal compression, in my current case the archive is
# only 300K instead of 12M.

require 'fileutils'
require 'optparse'
require 'tmpdir'
require 'open-uri'
include FileUtils

def sh(*cmd)
  puts cmd.join(' ')
  warn("Bad exit-status") unless system(*cmd)
end

def vendor_github(name_project_branch, target)
  name, project, branch = name_project_branch.split('/')
  branch ||= 'master'
  uri = "http://github.com/#{name}/#{project}/tarball/#{branch}"
  tar_name = [name, project, branch].join('-') + '.tar'

  Dir.chdir(target) do
    dirs_before = Dir['*']

    puts "Downloading #{uri} ..."
    File.open(tar_name, 'w+'){|tar| tar.write(open(uri).read) }
    puts "done."

    sh('tar', 'xf', tar_name)
    rm_f(tar_name)

    unpacked_tar_dir = (Dir['*'] - dirs_before).first
    mv(unpacked_tar_dir, project)

    Dir.glob(File.join(project, '*')) do |path|
      rm_r(path) unless File.basename(path) == 'lib'
    end
  end
end

def vendor_remote(repo, target)
  prefix = File.join(File.basename(repo, '.*'), '/')

  mkdir_p(target)

  sh("git archive --remote='#{repo}' --format=tar --prefix='#{prefix}' HEAD lib | (cd '#{target}' && tar xf -)")
end

def vendor_local(repo, target)
  repo = File.expand_path(repo)
  prefix = File.join(File.basename(repo, '.*'), '/')

  mkdir_p(target)

  Dir.chdir repo do
    sh("git archive --format=tar --prefix='#{prefix}' HEAD lib | (cd '#{target}' && tar xf -)")
  end
end

def sandbox(source, name, dependencies = {})
  Dir.mktmpdir('sandbox-') do |target|
    puts "Building sandbox in #{target}"

    target_dir = File.join(target, name)
    target_tar = File.expand_path(File.join(source, "#{name}.tar.bz2"))
    target_vendor = File.join(target_dir, 'vendor')

    mkdir_p(target_dir)

    sh("git archive --format=tar HEAD | (cd '#{target_dir}' && tar xf -)")

    dependencies.each do |type, repos|
      repos.uniq!

      case type
      when :local
        repos.each{|repo| vendor_local(repo, target_vendor) }
      when :remote
        repos.each{|repo| vendor_remote(repo, target_vendor) }
      when :github
        repos.each{|repo| vendor_github(repo, target_vendor) }
      else
        raise(ArgumentError, "Invalid dependency type: %p" % type)
      end
    end

    Dir.chdir(target) do |now|
      sh('tar', '-cjf', target_tar, name)
    end

    puts '', "All done, have fun playing, sandbox is waiting at #{target_tar}"
  end
end

source = Dir.pwd
name = File.basename(source)
locals = []
remotes = []
githubs = []

op = OptionParser.new{|o|
  o.on('-s', '--source DIR',
       'Sandbox this directory, defaults to current working directory'){|s| source = s }
  o.on('-n', '--name STRING',
       'Name of the final sandbox, default to basename of source'){|n| name = n }
  o.on('-d', '--dependencies repo1,repo2,repo3', Array,
       'Put archives of these git repos into target/vendor'){|d| locals += d }
  o.on('-r', '--remote uri1,uri2,uri3', Array,
       'Put archives of these remote git repos into target/vendor'){|r| remotes += r }
  o.on('-g', '--github name/proj,name/proj/branch', Array,
       'Retrieve tarballs from github for given projects, branch defaults to master'){|g| githubs += g }
  o.on('-h', '--help'){ puts o; exit }
}

if ARGV.empty?
  puts op
  exit 1
end

op.parse!(ARGV)

sandbox(source, name, :local => locals, :remote => remotes, :github => githubs)
