require 'ostruct'
require "build_box/version"
require "build_box/config"
require "build_box/response"
require "build_box/perform"

module BuildBox
  extend self

  def configure
    block_given? ? yield(BuildBox::Config) : BuildBox::Config
  end
  alias :config :configure

  def perform(code, binding_context=TOPLEVEL_BINDING)
    BuildBox::Response.new(code, binding_context)
  end

end
