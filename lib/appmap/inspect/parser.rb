require 'appmap/parser'
require 'appmap/inspect/parse_node'

module AppMap
  module Inspect
    # Parser processes a Ruby into a list of parse nodes and a list of comments.
    class Parser < ::AppMap::Parser
      protected

      def build_parse_node(node, file_path, ancestors)
        ParseNode.from_node(node, file_path, ancestors)
      end
    end
  end
end
