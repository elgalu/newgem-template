# System extension
module Kernel
  # Poor man logger
  def system_with_say(cmd)
    say "  #{cmd}"
    system cmd
  end
end

# Internal helper
module GemNewgem
  module Templates
    class Default < Thor::Group

      module Helper
        def gem_summary
          options['gem_summary']
        end

        def namespaced_path
          gem_name.tr('-', '/')
        end

        def constant_name
          cname = gem_name.split('_').map{|p| p[0..0].upcase + p[1..-1] }.join
          cname = cname.split('-').map{|q| q[0..0].upcase + q[1..-1] }.join('::') if cname =~ /-/
          cname
        end

        def constant_array
          constant_name.split('::')
        end

        def author
          git_user_name = `git config user.name`.chomp
          if git_user_name.empty?
            say "WARN: Couldn't find 'git config user.name' so will use general text."
            "TODO: Write your name"
          else
            git_user_name
          end
        end

        def email
          git_user_email = `git config user.email`.chomp
          if git_user_email.empty?
            say "WARN: Couldn't find 'git config user.email' so will use general text."
            "TODO: Write your email address"
          else
            git_user_email
          end
        end

        def github_user
          username = `git config github.user`.chomp
          if username.empty?
            say "WARN: Couldn't find 'git config github.user' so will use general text."
            "TODO: Write your github username"
          else
            username
          end
        end
      end

    end
  end
end
