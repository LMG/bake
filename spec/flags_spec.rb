#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

  class DummyFlags
    attr_accessor :overwrite
    attr_accessor :add
    attr_accessor :remove

    def initialize(o,a,r)
      @overwrite = o
      @add = a
      @remove = r
    end
  end

describe "Flags" do

  it 'overwrite' do
    df = DummyFlags.new("-f -g","","")
    orgStr = "-x -y -z"
    expect(adjustFlags(orgStr,[df])).to be == "-f -g"
  end

  it 'overwrite2' do
    df = DummyFlags.new("-f -g","-k","")
    df2 = DummyFlags.new("-h -i","","")
    orgStr = "-x -y -z"
    expect(adjustFlags(orgStr,[df, df2])).to be == "-h -i"
  end


  it 'add' do
    df = DummyFlags.new("","-f -g","")
    orgStr = "-x -y -z"
    expect(adjustFlags(orgStr,[df])).to be == "-x -y -z -f -g"
  end

  it 'add2' do
    df = DummyFlags.new("","-f -x -g","")
    df2 = DummyFlags.new("","-f -h","")
    orgStr = "-x -y -z"
    expect(adjustFlags(orgStr,[df, df2])).to be == "-x -y -z -f -x -g -f -h"
  end

  it 'remove' do
    df = DummyFlags.new("","","-f -g -y -y -z")
    orgStr = "-x -y -z"
    expect(adjustFlags(orgStr,[df])).to be == "-x"
  end

  it 'remove2' do
    df = DummyFlags.new("","","-x.x -z.* -y")
    orgStr = "-xxx -yyy -zzz"
    expect(adjustFlags(orgStr,[df])).to be == "-yyy"
  end

  it 'complex' do
    df = DummyFlags.new("","-a","-b")
    df1 = DummyFlags.new("-c -d","-h","-d")
    df2 = DummyFlags.new("","-e","-f")
    orgStr = "-x -y -z"
    expect(adjustFlags(orgStr,[df,df1,df2])).to be == "-c -h -e"
  end

  it 'duplicate' do
    Bake.startBake("artifact/main", ["test_Default_flags", "-v2"])
    expect(($mystring.include?"lib.d -x1 -x2 -x1 -x2 -x1 -x3 -x1 -x3 -x1 -o ")).to be == true
  end

  it 'remove string with needs to be escaped for regex' do
    Bake.startBake("flags/main", ["-v2", "--adapt", "spec/testdata/flags/main"])
    expect(($mystring.include?"build/test/x.d -std=gnu++14 -g -o build/test/x.o")).to be == true
  end


end

end
