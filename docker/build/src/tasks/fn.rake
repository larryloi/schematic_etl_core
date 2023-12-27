require_relative '../lib/schematic/fn'

namespace :fn do
  desc "Create a functions template file "
  task :create, :name do |_, args|
    unless args.name
      abort 'Aborted! Stored procedure name is missing.'
      exit 1
    end

    Schematic::Fn.new.create(args.name)
  end

  desc "Apply function"
  task :deploy do |_, args|
    Schematic::Fn.new.deploy unless Dir.glob("#{ENV['APP_HOME']}/functions/*.sql").empty?
  end
end