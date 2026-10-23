# frozen_string_literal: true

# Mints the next immutable ruby@X.Y.Z formula from the newest one of the same
# minor, with the tarball, rubygems resource and openssl dependency core's
# ruby.rb ships for that patch. Pure: reads and writes only what it is given.
# bin/mint-ruby-formula fetches core and calls in; the bump-ruby workflow
# drives it on a schedule.
module MintRubyFormula
  # Core's ruby.rb declares a dependency this family's template does not (or
  # vice versa) — beyond the openssl major, which render substitutes. A human
  # adapts the template lineage by hand; see README "Conventions".
  class DependencyDrift < StandardError; end

  # No ruby@X.Y.*.rb exists to template a new minor from.
  class NoTemplate < StandardError; end

  VERSION_PATTERN = /\d+\.\d+\.\d+/
  SHA256_PATTERN = /\h{64}/

  # What core's Formula/r/ruby.rb says about the Ruby it currently ships.
  Release = Struct.new(:version, :tarball_url, :tarball_sha256, :rubygems_version, :rubygems_sha256,
                       :dependencies, :core_commit, keyword_init: true) do
    # @param formula_rb [String] core's ruby.rb source
    # @param core_commit [String] the homebrew/core commit it was read at
    def self.from_core(formula_rb:, core_commit:)
      tarball_url, tarball_sha256 = url_and_sha256(formula_rb, %r{https://cache\.ruby-lang\.org/pub/ruby/[^"]+\.tar\.gz})
      rubygems_url, rubygems_sha256 = url_and_sha256(formula_rb, %r{https://rubygems\.org/rubygems/rubygems-[^"]+\.tgz})
      new(
        version:          tarball_url[/ruby-(#{VERSION_PATTERN})\.tar\.gz/, 1],
        tarball_url:      tarball_url,
        tarball_sha256:   tarball_sha256,
        rubygems_version: rubygems_url[/rubygems-(#{VERSION_PATTERN})\.tgz/, 1],
        rubygems_sha256:  rubygems_sha256,
        dependencies:     MintRubyFormula.dependency_names(formula_rb),
        core_commit:      core_commit,
      )
    end

    def self.url_and_sha256(source, url_pattern)
      match = source.match(/url "(#{url_pattern})"\s*\n\s*sha256 "(#{SHA256_PATTERN})"/)
      raise ArgumentError, "no url+sha256 matching #{url_pattern.source} in core's ruby.rb" unless match

      [match[1], match[2]]
    end

    def openssl
      dependencies.grep(/\Aopenssl@/).first
    end

    def minor
      version[/\A\d+\.\d+/]
    end
  end

  class << self
    # Every formula name `depends_on` or `uses_from_macos` declares for the
    # stable build, sorted. Core's `head do ... end` block is skipped: the
    # minted formula has no head.
    def dependency_names(formula_rb)
      stable_only = formula_rb.sub(/^  head do\n.*?^  end\n/m, "")
      stable_only.scan(/^\s*(?:depends_on|uses_from_macos) "([^"]+)"/).flatten.sort
    end

    # Path of the newest ruby@<minor>.*.rb in formula_dir.
    def template_for(version:, formula_dir:)
      minor = version[/\A\d+\.\d+/]
      candidates = Dir[File.join(formula_dir, "ruby@#{minor}.*.rb")]
      raise NoTemplate, "no ruby@#{minor}.*.rb in #{formula_dir} to template #{version} from; mint it by hand from core" if candidates.empty?

      candidates.max_by { |path| Gem::Version.new(path[/ruby@(#{VERSION_PATTERN})\.rb\z/, 1]) }
    end

    # The template re-pointed at release: version everywhere, class name,
    # tarball and rubygems sources, openssl major, header provenance; bottle
    # block dropped so the Bottle workflow bottles the new formula.
    def render(template:, release:)
      template_version = template[%r{/ruby-(#{VERSION_PATTERN})\.tar\.gz}, 1]
      template_openssl = dependency_names(template).grep(/\Aopenssl@/).first
      check_dependencies!(template: template, release: release, template_openssl: template_openssl)

      text = template.gsub(/(?<![\d.])#{Regexp.escape(template_version)}(?![\d])/, release.version)
      text = text.sub(/class RubyAT\d+ < Formula/, "class RubyAT#{release.version.delete(".")} < Formula")
      text = replace_url_and_sha256(text, %r{https://cache\.ruby-lang\.org/pub/ruby/[^"]+\.tar\.gz},
                                    release.tarball_url, release.tarball_sha256)
      text = replace_url_and_sha256(text, %r{https://rubygems\.org/rubygems/rubygems-[^"]+\.tgz},
                                    "https://rubygems.org/rubygems/rubygems-#{release.rubygems_version}.tgz",
                                    release.rubygems_sha256)
      text = text.gsub(template_openssl, release.openssl) if template_openssl && release.openssl
      text = text.sub(/^  bottle do\n.*?^  end\n\n/m, "")
      text.sub(/^# Derived from homebrew\/core's Formula\/r\/ruby\.rb at .*?:\n/m,
               "# Derived from homebrew/core's Formula/r/ruby.rb at #{release.core_commit[0, 8]} (ruby #{release.version}), templated\n" \
               "# from ruby@#{template_version}.rb by bin/mint-ruby-formula:\n")
    end

    # Writes Formula/ruby@<version>.rb from the newest same-minor formula.
    # @return [String, nil] the path written, or nil when it already exists
    def mint(release:, formula_dir:)
      path = File.join(formula_dir, "ruby@#{release.version}.rb")
      return nil if File.exist?(path)

      template = File.read(template_for(version: release.version, formula_dir: formula_dir))
      File.write(path, render(template: template, release: release))
      path
    end

    private

    def check_dependencies!(template:, release:, template_openssl:)
      expected = dependency_names(template).map { |name| name == template_openssl ? release.openssl : name }.sort
      return if expected == release.dependencies

      raise DependencyDrift,
            "core's ruby.rb at #{release.core_commit[0, 8]} depends on #{release.dependencies.join(", ")}; " \
            "the template depends on #{expected.join(", ")}. Adapt the template lineage by hand."
    end

    def replace_url_and_sha256(text, url_pattern, url, sha256)
      text.sub(/url "#{url_pattern}"(\s*\n\s*)sha256 "#{SHA256_PATTERN}"/) { %(url "#{url}"#{Regexp.last_match(1)}sha256 "#{sha256}") }
    end
  end
end
