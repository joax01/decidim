# frozen_string_literal: true

module Decidim
  # The controller to show all the last activities in a Decidim Organization.
  class UserActivitiesController < Decidim::ApplicationController
    include Paginable
    include UserGroups
    include FilterResource
    include Flaggable

    helper Decidim::ResourceHelper
    helper_method :activities, :resource_types, :user

    def index
      raise ActionController::RoutingError, "Missing user: #{params[:nickname]}" unless user
      raise ActionController::RoutingError, "Blocked User" if user.blocked? && !current_user&.admin?
    end

    private

    def user
      @user ||= current_organization.users.find_by(nickname: params[:nickname])
    end

    def activities
      @activities ||= paginate(
        ActivitySearch.new(
          organization: current_organization,
          user: user,
          current_user: current_user,
          resource_type: "all",
          resource_name: filter.resource_type
        ).run
      )
    end

    def default_filter_params
      { resource_type: nil }
    end

    def resource_types
      @resource_types = %w(Decidim::Proposals::CollaborativeDraft
                           Decidim::Comments::Comment
                           Decidim::Debates::Debate
                           Decidim::Initiative
                           Decidim::Meetings::Meeting
                           Decidim::Blogs::Post
                           Decidim::Proposals::Proposal
                           Decidim::Consultations::Question)
    end
  end
end
