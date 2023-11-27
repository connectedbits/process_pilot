# frozen_string_literal: true

module Zeebe
  class AssignmentDefinition
    attr_accessor :assignee, :candidate_groups, :candidate_users

    def initialize(moddle)
      @assignee = moddle["assignee"]
      @candidate_groups = moddle["candidateGroups"]
      @candidate_users = moddle["candidateUsers"]
    end
  end
end
