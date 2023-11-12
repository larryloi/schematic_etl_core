# frozen-string-literal: true

require "pathname"
require_relative "../../cipher"

module Schematic
  class Generator
    class GitOpsConfig
      attr_reader :options
      attr_reader :default_options

      def initialize(opts = {})
        @options = opts
        yield @options if block_given?
        on_init
        set_default_options
        set_default_values
      end

      def templates_dir
        @templates_dir ||= init_templates_dir
      end

      def base_templates_dir
        @base_templates_dir ||= File.join(templates_dir, 'base')
      end

      def configmap_templates_dir
        @configmap_templates_dir ||= File.join(templates_dir, 'overlays', 'dev', 'configmap')
      end

      def default_templates_dir
        File.join(__dir__, 'templates')
      end

      def work_dir
        @work_dir ||= init_work_dir
      end

      def default_work_dir = Dir.pwd

      def gitops_dir
        @gitops_dir ||= init_gitops_dir
      end

      def default_gitops_dir = 'gitops'

      def base_dir
        @base_dir ||= File.join(gitops_dir, 'base')
      end

      def overlays_dir
        @overlays_dir ||= File.join(gitops_dir, 'overlays')
      end

      def dev_overlays_dir
        @dev_overlays_dir ||= File.join(overlays_dir, 'dev')
      end

      def dev_configmap_dir
        @dev_configmap_dir ||= File.join(dev_overlays_dir, 'configmap')
      end

      def dev_jobs_configmap_dir
        @dev_jobs_configmap_dir ||= File.join(dev_configmap_dir, 'jobs')
      end

      def jobs_config_dir
        @jobs_config_dir ||= File.join(ENV['ENV_HOME'], 'jobs')
      end

      def app
        @app||= ENV['APP_NAME'].gsub('_', '-')
      end

      def project
        @project ||= ENV['PROJECT_NAME'].gsub('_', '-')
      end

      protected

      def on_init; end

      def set_default_options
        @default_options ||= {
          work: default_work_dir,
          gitops_dir: default_gitops_dir
        }
      end

      def set_default_values
        @options = default_options.merge(@options)
      end

      def init_templates_dir
        (options[:templates_dir] || default_templates_dir)
      end

      def init_work_dir
        (options[:work_dir] || default_work_dir)
      end

      def init_gitops_dir
        dir = Pathname.new(options[:gitops_dir] || default_gitops_dir)
        dir.absolute? ? dir.to_s : File.join(work_dir, dir.to_s)
      end

      def db_password_encrypted
        @options['db_password_encrypted'] ||=
          ENV['DB_PASSWORD_ENCRYPTED'].nil? ||
          ENV['DB_PASSWORD_ENCRYPTED'].empty? ?
            Schematic::Cipher.new.encrypt(ENV['DB_PASSWORD']) :
            ENV['DB_PASSWORD_ENCRYPTED']
      end
    end
  end
end
