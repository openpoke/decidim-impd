# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      module Censuses
        class TokenCsvFlexibleForm < TokenCsvForm
          def parse_csv_data
            return @csv_data if defined?(@csv_data)
            return nil if file.blank?

            file_io = StringIO.new(file.download)
            @csv_data = FlexibleCsvCensus::Data.new(file_io)
          rescue CSV::MalformedCSVError
            errors.add(:file, :malformed)
            @csv_data = nil
          end
        end
      end
    end
  end
end
