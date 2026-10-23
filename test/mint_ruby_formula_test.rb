# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "../lib/mint_ruby_formula"

class MintRubyFormulaTest < Minitest::Test
  TEMPLATE = <<~RUBY
    # Ruby 4.0.6, pinned. One immutable formula per Ruby patch; add ruby@X.Y.Z.rb
    # gives a project 4.0.6 and keeps giving it to it, and ruby-build compiles
    # because dev activates Cellar/ruby@4.0.6/4.0.6/bin per project itself.
    #
    # Derived from homebrew/core's Formula/r/ruby.rb at ad320c5d (ruby 4.0.6_1):
    # same configure, same rubygems resource, same deps.
    class RubyAT406 < Formula
      desc "Powerful, clean, object-oriented scripting language"
      url "https://cache.ruby-lang.org/pub/ruby/4.0/ruby-4.0.6.tar.gz"
      sha256 "837d299e8f7ddf2be31a229a7a7e019d354979825117989acb3b32b1a9be262a"
      license "Ruby"

      bottle do
        root_url "https://github.com/d3mlabs/homebrew-d3mlabs/releases/download/ruby@4.0.6-4.0.6"
        sha256 arm64_tahoe:  "aaaa"
        sha256 x86_64_linux: "bbbb"
      end

      keg_only :versioned_formula

      depends_on "pkgconf" => :build
      depends_on "rust" => :build
      depends_on "libyaml"
      depends_on "openssl@3"

      uses_from_macos "libffi"
      uses_from_macos "libxcrypt"

      on_linux do
        depends_on "zlib-ng-compat"
      end

      resource "rubygems" do
        url "https://rubygems.org/rubygems/rubygems-4.0.16.tgz"
        sha256 "ea9c669526af82874f8f33f69bea1b6ddd99283756e598227a9a890035a5a06a"
      end

      def install
        paths = %w[libyaml openssl@3].map { |f| formula_opt_prefix(f) }
      end
    end
  RUBY

  CORE_RUBY_RB = <<~RUBY
    class Ruby < Formula
      stable do
        url "https://cache.ruby-lang.org/pub/ruby/4.0/ruby-4.0.9.tar.gz"
        sha256 "c35350682ff050b79702d57ade4516e7336063f510155d19fb2fb5b3f3909511"

        resource "rubygems" do
          url "https://rubygems.org/rubygems/rubygems-4.0.23.tgz"
          sha256 "843f89b1c9c35c28f7ccaf4580cde1e7b00dbd1907b46bcfdcdbc6afa7345e56"
        end
      end

      head do
        url "https://github.com/ruby/ruby.git", branch: "master"

        depends_on "autoconf" => :build
      end

      depends_on "pkgconf" => :build
      depends_on "rust" => :build
      depends_on "libyaml"
      depends_on "openssl@4"

      uses_from_macos "libffi"
      uses_from_macos "libxcrypt"

      on_linux do
        depends_on "zlib-ng-compat"
      end
    end
  RUBY

  def release
    MintRubyFormula::Release.from_core(formula_rb: CORE_RUBY_RB, core_commit: "3aa17c6cb938813ff54413a8e3ba0a003b2773e8")
  end

  def test_release_from_core_reads_tarball_rubygems_and_deps
    # Head-only dependencies (autoconf) are not part of the stable Ruby.
    assert_equal "4.0.9", release.version
    assert_equal "https://cache.ruby-lang.org/pub/ruby/4.0/ruby-4.0.9.tar.gz", release.tarball_url
    assert_equal "c35350682ff050b79702d57ade4516e7336063f510155d19fb2fb5b3f3909511", release.tarball_sha256
    assert_equal "4.0.23", release.rubygems_version
    assert_equal "843f89b1c9c35c28f7ccaf4580cde1e7b00dbd1907b46bcfdcdbc6afa7345e56", release.rubygems_sha256
    assert_equal %w[libffi libxcrypt libyaml openssl@4 pkgconf rust zlib-ng-compat], release.dependencies
  end

  def test_render_moves_version_class_sources_and_openssl
    rendered = MintRubyFormula.render(template: TEMPLATE, release: release)

    assert_includes rendered, "class RubyAT409 < Formula"
    assert_includes rendered, "# Ruby 4.0.9, pinned."
    assert_includes rendered, "Cellar/ruby@4.0.9/4.0.9/bin"
    assert_includes rendered, %(url "https://cache.ruby-lang.org/pub/ruby/4.0/ruby-4.0.9.tar.gz"\n  sha256 "c35350682ff050b79702d57ade4516e7336063f510155d19fb2fb5b3f3909511")
    assert_includes rendered, %(url "https://rubygems.org/rubygems/rubygems-4.0.23.tgz"\n    sha256 "843f89b1c9c35c28f7ccaf4580cde1e7b00dbd1907b46bcfdcdbc6afa7345e56")
    assert_includes rendered, %(depends_on "openssl@4")
    assert_includes rendered, "%w[libyaml openssl@4]"
    refute_includes rendered, "openssl@3"
    refute_includes rendered, "4.0.16"
    # Only the provenance line may still name the template's version.
    refute_includes rendered.sub("from ruby@4.0.6.rb", ""), "4.0.6"
  end

  def test_render_drops_the_bottle_block_so_the_bottle_workflow_bottles_it
    rendered = MintRubyFormula.render(template: TEMPLATE, release: release)

    refute_includes rendered, "bottle do"
    refute_includes rendered, "arm64_tahoe"
    assert_includes rendered, %(license "Ruby"\n\n  keg_only :versioned_formula)
  end

  def test_render_records_the_core_commit_and_template_in_the_header
    rendered = MintRubyFormula.render(template: TEMPLATE, release: release)

    assert_includes rendered,
                    "# Derived from homebrew/core's Formula/r/ruby.rb at 3aa17c6c (ruby 4.0.9), templated\n" \
                    "# from ruby@4.0.6.rb by bin/mint-ruby-formula:"
    assert_includes rendered, "# same configure, same rubygems resource, same deps."
  end

  def test_render_refuses_dependency_drift_other_than_openssl
    drifted = CORE_RUBY_RB.sub(%(depends_on "libyaml"\n), "")
    drifted_release = MintRubyFormula::Release.from_core(formula_rb: drifted, core_commit: "3aa17c6c")

    error = assert_raises(MintRubyFormula::DependencyDrift) do
      MintRubyFormula.render(template: TEMPLATE, release: drifted_release)
    end
    assert_includes error.message, "libyaml"
  end

  def test_template_for_picks_the_newest_formula_of_the_same_minor
    Dir.mktmpdir do |dir|
      formula_dir = File.join(dir, "Formula")
      FileUtils.mkdir_p(formula_dir)
      %w[ruby@4.0.5.rb ruby@4.0.6.rb ruby@4.0.10.rb ruby@3.4.9.rb].each do |name|
        File.write(File.join(formula_dir, name), "# #{name}\n")
      end

      template = MintRubyFormula.template_for(version: "4.0.11", formula_dir: formula_dir)

      assert_equal File.join(formula_dir, "ruby@4.0.10.rb"), template
    end
  end

  def test_template_for_refuses_a_minor_with_no_formula
    Dir.mktmpdir do |dir|
      formula_dir = File.join(dir, "Formula")
      FileUtils.mkdir_p(formula_dir)
      File.write(File.join(formula_dir, "ruby@4.0.6.rb"), "# ruby@4.0.6.rb\n")

      error = assert_raises(MintRubyFormula::NoTemplate) do
        MintRubyFormula.template_for(version: "4.1.0", formula_dir: formula_dir)
      end
      assert_includes error.message, "4.1"
    end
  end

  def test_mint_writes_the_new_formula_next_to_the_template
    Dir.mktmpdir do |dir|
      formula_dir = File.join(dir, "Formula")
      FileUtils.mkdir_p(formula_dir)
      File.write(File.join(formula_dir, "ruby@4.0.6.rb"), TEMPLATE)

      path = MintRubyFormula.mint(release: release, formula_dir: formula_dir)

      assert_equal File.join(formula_dir, "ruby@4.0.9.rb"), path
      assert_includes File.read(path), "class RubyAT409 < Formula"
    end
  end

  def test_mint_returns_nil_when_the_formula_already_exists
    Dir.mktmpdir do |dir|
      formula_dir = File.join(dir, "Formula")
      FileUtils.mkdir_p(formula_dir)
      File.write(File.join(formula_dir, "ruby@4.0.6.rb"), TEMPLATE)
      File.write(File.join(formula_dir, "ruby@4.0.9.rb"), "# already here\n")

      assert_nil MintRubyFormula.mint(release: release, formula_dir: formula_dir)
      assert_equal "# already here\n", File.read(File.join(formula_dir, "ruby@4.0.9.rb"))
    end
  end
end
