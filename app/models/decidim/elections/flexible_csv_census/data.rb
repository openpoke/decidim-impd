# frozen_string_literal: true

require "csv"

module Decidim
  module Elections
    module FlexibleCsvCensus
      # Parses CSV census data with id and token columns.
      #
      # CSV format expected:
      #   id;token
      #   user123;ABC123
      #   member456;XYZ789
      #
      # Returns:
      #   - values: array of [id, token] pairs
      #   - errors: array of invalid rows
      class Data
        attr_reader :values, :errors

        def initialize(file)
          @values = []
          @errors = []
          @seen_ids = Set.new

          CSV.foreach(file, col_sep: Decidim.default_csv_col_sep, headers: true, encoding: "BOM|UTF-8") do |row|
            process_row(row)
          end
        end

        private

        def process_row(row)
          id = row["id"]&.strip
          token = row["token"]&.strip

          return if duplicate?(id)
          return errors << row if invalid?(id, token)

          values << [id, token]
        end

        def invalid?(id, token)
          id.blank? || token.blank?
        end

        def duplicate?(id)
          !@seen_ids.add?(id)
        end
      end
    end
  end
end
