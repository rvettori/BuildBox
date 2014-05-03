require 'spec_helper'

describe "BuildBox" do

  describe ".perform" do
    let(:correct_code){ '3+2+1'}
    let(:wrong_code){ '3+2+nil'}

    it "return result object" do
      expect(BuildBox.config).to receive(:bad_methods).and_return([])
      expect(BuildBox.config).to receive(:bad_constants).and_return([])
      result = BuildBox.perform(correct_code)
      expect(result).to be_a(BuildBox::Response)
      expect(result).to_not be_nil
    end

    it "correct code syntax" do
      expect(BuildBox.config).to receive(:bad_methods).and_return([])
      expect(BuildBox.config).to receive(:bad_constants).and_return([])
      result = BuildBox.perform(correct_code)
      expect(result.error?).to be_false
      expect(result.output).to eql(6)
    end

    it "wrong code syntax" do
      expect(BuildBox.config).to receive(:bad_methods).and_return([])
      expect(BuildBox.config).to receive(:bad_constants).and_return([])
      result = BuildBox.perform(wrong_code)
      expect(result.error?).to be_true
      expect(result.error).to_not be_empty
    end

    it 'allows constants to be used after uninitializing them' do
      expect(BuildBox.config).to receive(:bad_methods).and_return([])
      expect(BuildBox.config).to receive(:bad_constants).and_return([:Net])
      result = BuildBox.perform(' Net.methods')
      expect(result.error?).to be_true
      expect(Object.const_get(:Net)).to_not raise_error
    end

    it 'allows methods to be called after removing them' do
      expect(BuildBox.config).to receive(:bad_methods).and_return([[:Kernel, :exit]])
      expect(BuildBox.config).to receive(:bad_constants).and_return([])
      BuildBox.perform(['a = 1 + 1'])
      Kernel.methods.should include(:exit)
    end

    it 'waits timeout for perform code' do
      BuildBox.config.timeout = 0.1
      expect(BuildBox.config).to receive(:bad_methods).and_return([[:Kernel, :exit]])
      expect(BuildBox.config).to receive(:bad_constants).and_return([])
      result = BuildBox.perform('sleep 0.2')
      expect(result.error?).to be_true
    end

    it 'removes previous class definitions and methods between calls' do
      expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
      expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([])
      BuildBox.perform("class Foo \n def test \n 'hi' \n end \n end")
      expect(BuildBox.perform('Foo.new.test').error?).to  be_true #eql()"NameError: uninitialized constant Foo"
      expect(BuildBox.perform('Foo.new.test').error).to  eql("NameError: uninitialized constant Foo")
    end

    context 'unsafe commands' do
      it 'does not exit' do
        expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
        expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([])
        expect(BuildBox.perform('exit')).to be_error
      end

      it 'does not exit for kernel' do
        expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
        expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([])
        expect(BuildBox.perform('Kernel.exit').error).to eql("NameError: undefined local variable or method `exit' for Kernel:Module")
      end

      it 'does not exec' do
        expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
        expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([])
        expect(BuildBox.perform('exec("ps")').error).to eql("SecurityError: Insecure operation - exec")
      end

      it 'does not exec for kernel' do
        expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
        expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([])
        expect(BuildBox.perform('Kernel.exec("ps")').error).to eql("SecurityError: Insecure operation - exec")
      end

      it 'does not `' do
        expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
        expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([])
        expect(BuildBox.perform('`ls`').error).to eql("SecurityError: Insecure operation - `")
      end

      it 'does not implement File' do
        expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
        expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([:File])
        expect(BuildBox.perform('File').error).to eql("NameError: uninitialized constant File")
      end

      it 'does not implement Dir' do
        expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
        expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([:Dir])
        expect(BuildBox.perform('Dir').error).to eql("NameError: uninitialized constant Dir")
      end

      it 'does not implement IO' do
        expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
        expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([:IO])
        expect(BuildBox.perform('IO').error).to eql("NameError: uninitialized constant IO")
      end

      it 'does not implement Open3' do
        expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
        expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([:Open3])
        expect(BuildBox.perform('Open3').error).to eql("NameError: uninitialized constant Open3")
      end

      it 'does not implement Open3 even after requiring it' do
        expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
        expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([:Open3])
        expect(BuildBox.perform('require "open3"; Open3').error).to eql("SecurityError: Insecure operation - require")
      end

      it 'does not allow you to manually call protected BuildBox methods' do
        expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
        expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([:BuildBox])
        expect(BuildBox.perform('BuildBox.inspect').error).to eql("NameError: uninitialized constant BuildBox")
      end

      it 'does not allow you to manually call children of removed classes' do
        expect(BuildBox.config).to receive(:bad_methods).at_least(:once).and_return([])
        expect(BuildBox.config).to receive(:bad_constants).at_least(:once).and_return([:BuildBox])
        expect(BuildBox.perform('BuildBox::Config.inspect').error).to eql("NameError: uninitialized constant BuildBox")
      end
    end

  end # .perform

end