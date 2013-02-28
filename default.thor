#!/usr/bin/env ruby
gem 'thor-exclude_pattern', '>= 0.18'
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
      class_option :exclude_pattern, :default => %r!(\.git\/)|(#{@script_name}.*\.thor)!

      # The PATH containing your templates
      def self.source_root
        if defined?(GemNewgem::Newgem::Configuration)
          GemNewgem::Newgem::Configuration.instance.templates_base_dir
        else
          "~/.newgem-templates/"
        end
      end

      def bootstrap_gem
        # Ref: http://rdoc.info/github/wycats/thor/Thor/Actions#directory-instance_method
        opts = options['exclude_pattern'] ? { :exclude_pattern => options['exclude_pattern'] } : {}
        directory template_name, gem_name, opts
      end

      def initialize_git_repo
        Dir.chdir(gem_name) do
          say "INFO: Initializating git repo at #{gem_name}/"
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
  args = ARGV + ['default']
  script = GemNewgem::Templates::Default.new(args)
  script.invoke_all
end
