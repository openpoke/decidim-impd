# frozen_string_literal: true

# Register the flexible CSV census type for Elections.
Rails.application.config.after_initialize do
  Decidim::Elections.census_registry.register(:token_csv_flexible) do |manifest|
    manifest.admin_form = "Decidim::Elections::Admin::Censuses::TokenCsvFlexibleForm"
    manifest.admin_form_partial = "decidim/elections/admin/censuses/token_csv_flexible_form"
    manifest.voter_form = "Decidim::Elections::Censuses::TokenCsvFlexibleForm"
    manifest.voter_form_partial = "decidim/elections/censuses/token_csv_flexible_form"
    manifest.after_update_command = "Decidim::Elections::Admin::Censuses::TokenCsvFlexible"
    manifest.user_query do |election|
      Decidim::Elections::Voter.where(election: election)
    end
  end
end
