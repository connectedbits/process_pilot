# frozen_string_literal: true

module ProcessableServices
  class ScriptRunner < ApplicationService
    attr_reader :script, :variables, :procs

    def initialize(script:, variables: {}, procs: {})
      super()
      @script = script
      @variables = variables
      @procs = procs
    end

    def call
      ctx = MiniRacer::Context.new
      procs.each do |key, value|
        ctx.attach(key.to_s, value)
      end if procs
      ctx.eval "variables = #{variables.to_json}; #{script}"
    end
  end
end
