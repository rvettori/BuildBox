class BuildBox::Response

  attr_accessor :output, :error

  def initialize(code)
    evaluate(code)
  end

  def error?
    !@error.nil?
  end

  private

  def evaluate(code)
    preserve_namespace
    result  = BuildBox::Perform.new(code)
    @output = result.output
    @error  = result.error
    restore_namespace
    self
  end

  def preserve_namespace
    @old_constants = Object.constants
  end
  
  def restore_namespace
    (Object.constants - @old_constants).each {|bad_constant| Object.send(:remove_const, bad_constant)}
  end


end