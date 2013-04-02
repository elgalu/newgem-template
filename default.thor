#!/usr/bin/env ruby
gem 'thor', '>= 0.18.1'
require 'thor'
require_relative 'default_helper.thor.rb'

module GemNewgem
  module Templates

    class Default < Thor::Group
      include Thor::Actions
      include Helper

      @script_name = self.name.split('::').last.downcase

      argument :gem_name
      argument :template_name

      class_option :gem_summary,     :default => %q{TODO: Add your gem summary here.}
      class_option :exclude_pattern, :default => %r!(\.git\/)|(#{@script_name}.*\.thor)|(README\.markdown)!

      # The PATH containing your templates
      def self.source_root
        if defined?(GemNewgem::Newgem::Configuration)
          GemNewgem::Newgem::Configuration.instance.templates_base_dir
        else
          File.expand_path('../..', __FILE__)
        end
      end

      def bootstrap_gem
        # Ref: http://rdoc.info/github/wycats/thor/Thor/Actions#directory-instance_method
        opts = options['exclude_pattern'] ? { :exclude_pattern => options['exclude_pattern'] } : {}
        directory template_name, gem_name, opts
      end

      def initialize_git_repo
        Dir.chdir(gem_name) do
          say "INFO: Initializing git repo at #{gem_name}/"
          system_with_say "git init"
          system_with_say "git add ."

          say "INFO: Will add remote so you get ready to push to github"
          system_with_say("git remote add github git@github.com:#{github_user}/#{gem_name}.git")

          say "INFO: Make branch tracking automatic"
          system_with_say "git config --add branch.master.remote github"
          system_with_say "git config --add branch.master.merge refs/heads/master"
        end
      end
    end

  end
end

if $0 == __FILE__
  # Scripted main
  unless ARGV[0].to_s.match /\w+/
    puts "Usage: #{$0} GEMNAME [--summary 'TODO: write summary']"
    exit 1
  end
  args = [ARGV[0], 'default']
  opts = ["-s", "--summary"].include?(ARGV[1].to_s.strip) ? { gem_summary: ARGV[2] } : {}
  script = GemNewgem::Templates::Default.new(args, opts)
  script.invoke_all
end
