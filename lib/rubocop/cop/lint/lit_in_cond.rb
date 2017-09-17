# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Lint
      class LitInCond < Cop
        MSG = 'Do not use a literal in condition'.freeze

        def on_if(node)
          cond = node.children.first
          if cond.type == :int
            add_offense(cond)
          end
        end
      end
    end
  end
end
