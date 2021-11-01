# frozen_string_literal: true

module ProcessableServices
  class ScriptRunner < ApplicationService
    attr_reader :script, :variables, :utils

    def initialize(script:, variables: {}, utils: {})
      super()
      @script = script
      @variables = variables
      @utils = utils
    end

    def call
      ctx = MiniRacer::Context.new
      utils.each do |key, value|
        ctx.attach(key.to_s, value)
      end if utils
      ctx.eval "variables = #{variables.to_json}; #{script}"
    end
  end
end
