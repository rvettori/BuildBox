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

  def perform(code)
    BuildBox::Response.new(code)
  end

end
