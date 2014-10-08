package = "yarrrconfig"
version = "0.1-1"
source = {
  url = "git://github.com/yarrrthegame/yarrrconfig",
  tag = "master",
}

description = {
  summary = "yarrr game configuration helper.",
  detailed = [[
    This package provides some basic code to help
    yarrr configuration file writing.
  ]],
  homepage = "http://yarrrthegame.github.com/yarrrconfig",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    yarrrconfig = "src/yarrrconfig.lua",
  }
}

