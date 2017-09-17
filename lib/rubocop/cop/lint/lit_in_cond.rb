# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Lint
      class LitInCond < Cop
        MSG = 'Do not use a literal in condition'.freeze

        def_node_matcher :lit_in_cond?, <<-PATTERN
          (if int ...)
        PATTERN

        def on_if(node)
          lit_in_cond?(node) do
            cond = node.children.first
            add_offense(cond)
          end
        end
      end
    end
  end
end
