# frozen_string_literal: true

module Decidim
  module Elections
    module Censuses
      # Voter authentication form for flexible CSV census.
      class TokenCsvFlexibleForm < Decidim::Form
        attribute :id, String
        attribute :token, String

        validates :id, presence: true
        validates :token, presence: true

        validate :data_in_census

        def voter_uid
          @voter_uid ||= census_user&.to_global_id&.to_s
        end

        def census_user
          election.census.users(election).where(
            "data->>'id' = ? AND data->>'token' = ?",
            id&.strip,
            token&.strip
          )&.first
        end

        def election
          @election ||= context.election
        end

        private

        def data_in_census
          return if voter_uid.present?

          errors.add(:base, I18n.t("decidim.elections.censuses.token_csv_flexible_form.invalid"))
        end
      end
    end
  end
end
