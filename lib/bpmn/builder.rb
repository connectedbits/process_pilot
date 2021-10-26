module Bpmn
  class Builder
    attr_reader :id, :name, :elements, :processes, :messages, :signals, :errors

    def initialize(moddle)      
      root_element = moddle["rootElement"]
      @id = root_element["id"]
      @name = root_element["name"]

      @elements = {}
      @messages = []
      @signals = []
      @errors = []
      @processes = []

      # Create element map
      moddle["elementsById"].values.each do |element_json|
        next if element_json["$type"].start_with?("bpmndi") || element_json["$type"] == "bpmn:Definitions"
        element = Element.from_moddle(element_json)
        @elements[element.id] = element if element
      end

      # Wireup references
      moddle["references"].each do |reference_json|
        next if reference_json["element"]["$type"]&.start_with?("bpmndi")
        case reference_json["property"]
        when "bpmn:incoming"
          flow_object = @elements[reference_json["element"]["id"]]
          flow_object.incoming.push @elements[reference_json["id"]] if flow_object
        when "bpmn:outgoing"
          flow_object = @elements[reference_json["element"]["id"]]
          flow_object.outgoing.push @elements[reference_json["id"]] if flow_object
        when "bpmn:sourceRef"
          sequence_flow = @elements[reference_json["element"]["id"]]
          sequence_flow.source = @elements[reference_json["id"]] if sequence_flow
        when "bpmn:targetRef"
          sequence_flow = @elements[reference_json["element"]["id"]]
          sequence_flow.target = @elements[reference_json["id"]] if sequence_flow
        when "bpmn:default"
          gateway = @elements[reference_json["element"]["id"]]
          gateway.default = @elements[reference_json["id"]] if gateway
        when "bpmn:messageRef"
          message_definition = @elements[reference_json["element"]["id"]]
          message_definition.message_ref = @elements[reference_json["id"]] if message_definition
        when "bpmn:signalRef"
          signal_definition = @elements[reference_json["element"]["id"]]
          signal_definition.signal_ref = @elements[reference_json["id"]] if signal_definition
        else
          if reference_json["element"]["$type"] == "bpmn:BoundaryEvent"
            event = @elements[reference_json["element"]["id"]]
            owner = @elements[reference_json["id"]]
            if owner.bpmn_type != "SequenceFlow"
              event.attached_to = owner
              owner.attachments.push(event) if event
            end
          elsif reference_json["element"]["$type"] == "bpmn:MessageEventDefinition"
            message = @elements[reference_json["id"]]
            message_definition = @elements[reference_json["element"]["id"]]
            message_definition.message_ref = message.id
            message_definition.message = message
          elsif reference_json["element"]["$type"] == "bpmn:SignalEventDefinition"
            signal = @elements[reference_json["id"]]
            signal_definition = @elements[reference_json["element"]["id"]]
            signal_definition.signal_ref = signal.id
            signal_definition.signal = signal
          elsif reference_json["element"]["$type"] == "bpmn:ErrorEventDefinition"
            error = @elements[reference_json["id"]]
            error_definition = @elements[reference_json["element"]["id"]]
            error_definition.error_ref = error.id
            error_definition.error = error
          else
            ap "Unhandled reference #{reference_json["property"]}"
          end
        end
      end

      moddle["rootElement"]["rootElements"].each do |element_json|
        if element_json["$type"] == "bpmn:Process"
          process = load_process(element_json, parent: nil)
          @processes.push process
          @root_process = process
        elsif element_json["$type"] == "bpmn:Message"
          @messages.push Element.new(element_json)
        elsif element_json["$type"] == "bpmn:Signal"
          @signals.push Element.new(element_json)
        elsif element_json["$type"] == "bpmn:Error"
          @errors.push Element.new(element_json)
        end
      end
    end

    def process_by_id(id)
      processes.find { |p| p.id == id }
    end

    def element_by_id(id)
      elements[id.to_s]
    end

    def element_ids
      elements.keys
    end

    private

    def load_process(element_json, parent: nil)
      process = elements[element_json["id"]]
      process.parent = parent
      element_json['flowElements'].each do |flow_element|
        element = @elements[flow_element["id"]]
        next unless element
        process.elements.push element
        if element.type == "SubProcess"
          sub_process = load_process(child_element_json, parent: process)
          process.sub_processes.push sub_process
        elsif element.type == "AdHocSubProcess"
          ad_hoc_sub_process = load_process(child_element_json, parent: process)
          process.sub_processes.push ad_hoc_sub_process
        end
      end if element_json['flowElements']
      @processes.push = process if process.type == "Process"
      process
    end
  end
end