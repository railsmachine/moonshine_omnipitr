require 'spec_helper'

describe "A manifest with the Omnipitr plugin" do

  before do
    @manifest = OmnipitrManifest.new
    @manifest.omnipitr
  end

  it "should be executable" do
    @manifest.should be_executable
  end

  #it "should provide packages/services/files" do
  # @manifest.packages.keys.should include 'foo'
  # @manifest.files['/etc/foo.conf'].content.should match /foo=true/
  # @manifest.execs['newaliases'].refreshonly.should be_true
  #end

end