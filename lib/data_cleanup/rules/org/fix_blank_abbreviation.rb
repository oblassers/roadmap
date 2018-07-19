module DataCleanup
  module Rules
    module Org
      class FixBlankAbbreviation < Rules::Base

        YAML_FILE_PATH = Rails.root.join("lib", "data_cleanup", "rules", "org",
                                         "fix_blank_abbreviation.yml")

        def description
          "Fix blank abbreviation on Org"
        end

        def call
          YAML.load_file(YAML_FILE_PATH).each do |attributes|
            ::Org.where(name: attributes['name'], id: attributes['id'])
                 .update_all(abbreviation: attributes['abbreviation'])
          end
        end
      end
    end
  end
end
