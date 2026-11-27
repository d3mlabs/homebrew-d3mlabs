# typed: false
# frozen_string_literal: true

# Dependency manifest for dev. The tap's toolchain is brew's own; this
# declares the ai-flow dispatcher its ai-commands workflow runs — a 1.x
# release, resolved through the series head `v1`, the same ref the
# caller's `uses: …@v1` resolves. A major bump edits this line and the
# caller. Re-lock with `dev deps update ai-flow`.
require "dev/deps"

Dev::Deps.define do
  group :build do
    gh "d3mlabs/ai-flow", "^1", assets: "ai-flow-*.zip"
  end
end
