require 'pathname'

module Schematic
  class Fn

    def create(fnname)
      fn_template = <<~TEMPLATE
        CREATE FUNCTION [dbo].[#{fnname}]()
        RETURNS INT
        AS
        BEGIN
          RETURN (1);
        END;
        TEMPLATE

      file_name = "#{fnname}.sql"
      FileUtils.mkdir_p(fn_dir)

      fn_file = File.join(fn_dir, file_name)

      File.open(fn_file, 'w') do |file|
        file.write(fn_template)
      end
      puts "New function template is created: #{fn_file}"
    end


    def deploy
      dir = Pathname.new(fn_dir)

      Dir.glob(dir.join('*.sql')) do |file|
        sql = File.read(file)

        # Split the SQL script into separate commands at each 'GO' statement
        commands = sql.split("\nGO")
        puts "\n  >> Executing script from #{file}\n"

        commands.each do |command|
          unless command.strip.empty?
            # Extract schema and function name from the command
            match_data = command.match(/CREATE\s+FUNCTION\s+\[(?<schema>.+)\]\.\[(?<function>.+)\]/i)
            next unless match_data
            
            schema_name = match_data[:schema]
            function_name = match_data[:function]

            db_name = @options[:db_name]
            # Check if the function exists
            check_sql = "SELECT * FROM sys.objects o JOIN sys.schemas s ON o.schema_id = s.schema_id WHERE type = 'FN' AND o.name = '#{function_name}' AND s.name = '#{schema_name}'"
            result = db_connection.fetch(check_sql).all
    
            if result.nil? || result.empty?
              puts "  >> Create new function.\n\n"
              db_connection.run(command)
            else
              alter_command = command.gsub(/CREATE\s+FUNCTION/i, 'ALTER FUNCTION')
              puts "  >> Update existing function.\n\n"
              db_connection.run(alter_command)
            end


          end
        end
      end
    end
  end
end