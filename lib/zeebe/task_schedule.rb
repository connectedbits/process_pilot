# frozen_string_literal: true

module Zeebe
  class TaskSchedule < Bpmn::Extension
    attr_accessor :due_date, :follow_up_date

    def initialize(moddle)
      super(moddle)
      @due_date = moddle["dueDate"]
      @follow_up_date = moddle["followUpDate"]
    end
  end
end
