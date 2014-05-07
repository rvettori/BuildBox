class BuildBox::Response

  attr_accessor :output, :error, :code # TODO: return de evaluated code

  def initialize(code, binding_context)
    evaluate(code, binding_context)
  end

  def error?
    !@error.nil?
  end

  private

  def evaluate(code, binding_context)
    preserve_namespace
    result  = BuildBox::Perform.new(code, binding_context)
    @output = result.output
    @error  = result.error
    @code   = result.code
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