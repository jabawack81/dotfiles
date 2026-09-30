#!/usr/bin/env ruby
# frozen_string_literal: true

# Compare the vendored caelestia shell with the upstream tag it claims to be.
#
# Our changes to upstream files must be additions only. A deletion means an
# edit clobbered something, which is easy to do with a careless sed and stays
# invisible until the shell silently drops a component at runtime — removing
# a `colour: root.colour` binding once cost us the bluetooth, battery and
# lock icons, with nothing in the logs.
#
# Exits non-zero if any upstream line was removed.

require "tmpdir"
require "open3"

DIR = File.expand_path("../common/caelestia-shell", __dir__)
URL = "https://github.com/caelestia-dots/shell"
IGNORED = ["UPSTREAM", "CHANGES-LOCAL.md"].freeze

RED   = "\e[31m"
GREEN = "\e[32m"
BOLD  = "\e[1m"
RESET = "\e[0m"

def upstream_version
  File.read(File.join(DIR, "UPSTREAM"))[/^\s*version\s+(\S+)/, 1] or
    abort "#{RED}No version in #{DIR}/UPSTREAM#{RESET}"
end

def local_files
  Dir.glob("**/*", File::FNM_DOTMATCH, base: DIR)
     .reject { |f| f.start_with?("build/", ".git/") || IGNORED.include?(f) }
     .select { |f| File.file?(File.join(DIR, f)) }
end

version = upstream_version
puts "#{BOLD}Comparing #{File.basename(DIR)} with upstream #{version}#{RESET}"

failures = []
added_only = []

Dir.mktmpdir do |tmp|
  src = File.join(tmp, "src")
  _, err, status = Open3.capture3(
    "git", "-c", "advice.detachedHead=false", "clone", "-q",
    "--depth", "1", "--branch", version, URL, src
  )
  abort "#{RED}Could not fetch #{version}: #{err}#{RESET}" unless status.success?

  local_files.each do |rel|
    ours = File.join(DIR, rel)
    theirs = File.join(src, rel)

    # Files only we have are our own additions; nothing to compare.
    next unless File.exist?(theirs)

    diff, = Open3.capture2("diff", theirs, ours)
    next if diff.empty?

    removed = diff.lines.grep(/^< /)
    added   = diff.lines.grep(/^> /)

    if removed.empty?
      added_only << [rel, added.size]
    else
      failures << [rel, added.size, removed]
    end
  end

  # A file upstream has that we do not is also a problem.
  Dir.glob("**/*", base: src).each do |rel|
    next unless File.file?(File.join(src, rel))
    next if rel.start_with?(".git/")
    next if File.exist?(File.join(DIR, rel))

    failures << [rel, 0, ["(file missing from the vendored copy)\n"]]
  end
end

added_only.sort.each { |rel, n| puts "  #{GREEN}#{rel}: +#{n} -0#{RESET}" }

failures.sort.each do |rel, n, removed|
  puts "  #{RED}#{rel}: +#{n} -#{removed.size} — removes upstream lines#{RESET}"
  removed.first(10).each { |l| puts "      #{l.chomp}" }
  puts "      ... #{removed.size - 10} more" if removed.size > 10
end

if failures.empty?
  puts "#{GREEN}✓ Local changes are additions only#{RESET}"
  exit 0
else
  puts "#{RED}✗ #{failures.size} file(s) diverge from upstream by more than additions#{RESET}"
  exit 1
end
