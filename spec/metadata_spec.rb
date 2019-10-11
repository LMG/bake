#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'
require 'json'
module Bake

describe "Metadata" do

  it 'exe' do
    FileUtils.mkdir_p("spec/testdata/artifact/main/build")
    Bake.startBake("artifact/main", ["test_metadata_exe", "-Z", "metadata=spec/testdata/artifact/main/build/x.json"])
    data = JSON.parse(File.read("spec/testdata/artifact/main/build/x.json"))
    expect(data["module_path"].end_with?( "spec/testdata/artifact/main")).to be == true
    expect(data["config_name"]).to be  == "test_metadata_exe"
    expect(data["artifact"]).to be     == "build/test_metadata_exe/main#{Bake::Toolchain.outputEnding}"
    expect(data["compiler_c"]).to be   == "gcc"
    expect(data["compiler_cxx"]).to be == "cppcom"
    expect(data["flags_c"]).to be      == ""
    expect(data["flags_cxx"]).to be    == "-cppf1 -ccpf2"
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'lib' do
    FileUtils.mkdir_p("spec/testdata/artifact/main/build")
    Bake.startBake("artifact/main", ["test_metadata_lib", "-Z", "metadata=spec/testdata/artifact/main/build/x.json"])
    data = JSON.parse(File.read("spec/testdata/artifact/main/build/x.json"))
    expect(data["module_path"].end_with?( "spec/testdata/artifact/main")).to be == true
    expect(data["config_name"]).to be  == "test_metadata_lib"
    expect(data["artifact"]).to be     == "build/test_metadata_lib/libmain.a"
    expect(data["compiler_c"]).to be   == "gcc"
    expect(data["compiler_cxx"]).to be == "g++"
    expect(data["flags_c"]).to be      == "-cf1 -cf2"
    expect(data["flags_cxx"]).to be    == ""
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
