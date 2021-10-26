module ProcessableServices
  class ScriptRunner < ApplicationService
    attr_reader :script, :data, :context, :utils

    def initialize(script, data: {}, context: {}, utils: {})
      super()
      @script = script
      @data = data
      @context = context
      @utils = utils
    end

    def call
      ctx = MiniRacer::Context.new
      utils.each do |key, value|
        ctx.attach(key.to_s, value)
      end if utils
      ctx.eval "data = #{data.to_json}; context = #{context.to_json}; #{script}"
    end
  end
end
